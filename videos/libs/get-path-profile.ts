import {Vector2, clamp} from '@canvas-commons/core';
import { CubicBezierSegment, CurveProfile, LineSegment, QuadBezierSegment, Segment } from '@canvas-commons/2d';

const COMMAND_ARITY: Record<string, number> = {
  a: 7,
  c: 6,
  h: 1,
  l: 2,
  m: 2,
  q: 4,
  s: 4,
  t: 2,
  v: 1,
  z: 0,
};

export type PathCommand = [string, ...number[]];

function parseValues(args: string): number[] {
  const numbers = args.match(/-?[0-9]*\.?[0-9]+(?:e[-+]?\d+)?/gi);
  return numbers ? numbers.map(Number) : [];
}

function parse(path: string): PathCommand[] {
  const data: PathCommand[] = [];

  path.replace(/([astvzqmhlc])([^astvzqmhlc]*)/gi, (_, command: string, args: string) => {
    let type = command.toLowerCase();
    const values = parseValues(args);

    if (type === 'm' && values.length > 2) {
      data.push([command, ...values.splice(0, 2)]);
      type = 'l';
      command = command === 'm' ? 'l' : 'L';
    }

    while (true) {
      if (values.length === COMMAND_ARITY[type]) {
        data.push([command, ...values]);
        return '';
      }
      if (values.length < COMMAND_ARITY[type]) {
        throw new Error('malformed path data');
      }
      data.push([command, ...values.splice(0, COMMAND_ARITY[type])]);
    }
  });

  return data;
}

function addSegmentToProfile(profile: CurveProfile, segment: Segment) {
  profile.segments.push(segment);
  profile.arcLength += segment.arcLength;
}

function getArg(command: PathCommand, argumentIndex: number) {
  return command[argumentIndex + 1] as number;
}

function getVector2(command: PathCommand, argumentIndex: number) {
  return new Vector2(
    command[argumentIndex + 1] as number,
    command[argumentIndex + 2] as number,
  );
}

function getPoint(
  command: PathCommand,
  argumentIndex: number,
  isRelative: boolean,
  currentPoint: Vector2,
) {
  const point = getVector2(command, argumentIndex);
  return isRelative ? currentPoint.add(point) : point;
}

function reflectControlPoint(control: Vector2, currentPoint: Vector2) {
  return currentPoint.add(currentPoint.sub(control));
}

function updateMinSin(profile: CurveProfile) {
  for (let i = 0; i < profile.segments.length; i++) {
    const segmentA = profile.segments[i];
    const segmentB = profile.segments[(i + 1) % profile.segments.length];

    // In cubic bezier this equal p2.sub(p3)
    const startVector = segmentA.getPoint(1).tangent.scale(-1);
    // In cubic bezier this equal p1.sub(p0)
    const endVector = segmentB.getPoint(0).tangent;
    const dot = startVector.dot(endVector);

    const angleBetween = Math.acos(clamp(-1, 1, dot));
    const angleSin = Math.sin(angleBetween / 2);

    profile.minSin = Math.min(profile.minSin, Math.abs(angleSin));
  }
}

export function getPathProfile(data: string): CurveProfile {
  const profile: CurveProfile = {
    segments: [],
    arcLength: 0,
    minSin: 1,
  };

  const segments = parse(data);
  let currentPoint = new Vector2(0, 0);
  let firstPoint: Vector2 | null = null;

  for (const segment of segments) {
    const command = segment[0].toLowerCase();
    const isRelative = segment[0] === command;

    if (command === 'm') {
      currentPoint = getPoint(segment, 0, isRelative, currentPoint);
      firstPoint = currentPoint;
    } else if (command === 'l') {
      const nextPoint = getPoint(segment, 0, isRelative, currentPoint);
      addSegmentToProfile(profile, new LineSegment(currentPoint, nextPoint));
      currentPoint = nextPoint;
    } else if (command === 'h') {
      const x = getArg(segment, 0);
      const nextPoint = isRelative
        ? currentPoint.addX(x)
        : new Vector2(x, currentPoint.y);
      addSegmentToProfile(profile, new LineSegment(currentPoint, nextPoint));
      currentPoint = nextPoint;
    } else if (command === 'v') {
      const y = getArg(segment, 0);
      const nextPoint = isRelative
        ? currentPoint.addY(y)
        : new Vector2(currentPoint.x, y);
      addSegmentToProfile(profile, new LineSegment(currentPoint, nextPoint));
      currentPoint = nextPoint;
    } else if (command === 'q') {
      const controlPoint = getPoint(segment, 0, isRelative, currentPoint);
      const nextPoint = getPoint(segment, 2, isRelative, currentPoint);
      addSegmentToProfile(
        profile,
        new QuadBezierSegment(currentPoint, controlPoint, nextPoint),
      );
      currentPoint = nextPoint;
    } else if (command === 't') {
      const lastSegment = profile.segments[profile.segments.length - 1];
      const controlPoint =
        lastSegment instanceof QuadBezierSegment
          ? reflectControlPoint(lastSegment.p1, currentPoint)
          : currentPoint;

      const nextPoint = getPoint(segment, 0, isRelative, currentPoint);
      addSegmentToProfile(
        profile,
        new QuadBezierSegment(currentPoint, controlPoint, nextPoint),
      );
      currentPoint = nextPoint;
    } else if (command === 'c') {
      const startControlPoint = getPoint(segment, 0, isRelative, currentPoint);
      const endControlPoint = getPoint(segment, 2, isRelative, currentPoint);
      const nextPoint = getPoint(segment, 4, isRelative, currentPoint);
      addSegmentToProfile(
        profile,
        new CubicBezierSegment(
          currentPoint,
          startControlPoint,
          endControlPoint,
          nextPoint,
        ),
      );
      currentPoint = nextPoint;
    } else if (command === 's') {
      const lastSegment = profile.segments[profile.segments.length - 1];
      const startControlPoint =
        lastSegment instanceof CubicBezierSegment
          ? reflectControlPoint(lastSegment.p2, currentPoint)
          : currentPoint;

      const endControlPoint = getPoint(segment, 0, isRelative, currentPoint);
      const nextPoint = getPoint(segment, 2, isRelative, currentPoint);
      addSegmentToProfile(
        profile,
        new CubicBezierSegment(
          currentPoint,
          startControlPoint,
          endControlPoint,
          nextPoint,
        ),
      );
      currentPoint = nextPoint;
    } else if (command === 'a') {
      currentPoint = getPoint(segment, 5, isRelative, currentPoint);
    } else if (command === 'z') {
      if (!firstPoint) continue;
      if (currentPoint.equals(firstPoint)) continue;

      addSegmentToProfile(profile, new LineSegment(currentPoint, firstPoint));
      currentPoint = firstPoint;
    }
  }
  updateMinSin(profile);

  return profile;
}
