export function isTypedArray(
  value: unknown,
  type?: string,
): value is ArrayBufferView {
  if (!ArrayBuffer.isView(value)) return false;
  if (type == null) return true;
  const tag = Object.getPrototypeOf(value)?.constructor?.name;
  return tag === type;
}

export function toUsAsciiBytes(src: string): Int8Array {
  const n = src.length;
  const result = new Int8Array(n);
  for (let i = 0; i < n; ++i) result[i] = src.charCodeAt(i);
  return result;
}

export function toInt8Array(bs: string | BufferSource): Int8Array {
  if (typeof bs === "string") return toUsAsciiBytes(bs);
  if (bs instanceof Int8Array) return bs;
  if (ArrayBuffer.isView(bs)) {
    const { buffer, byteOffset, byteLength } = bs;
    return new Int8Array(buffer, byteOffset, byteLength);
  }
  return new Int8Array(bs);
}

export function toUint8Array(bs: string | BufferSource): Uint8Array {
  if (typeof bs === "string") return new TextEncoder().encode(bs);
  if (bs instanceof Uint8Array) return bs;
  if (ArrayBuffer.isView(bs)) {
    const { buffer, byteOffset, byteLength } = bs;
    return new Uint8Array(buffer, byteOffset, byteLength);
  }
  return new Uint8Array(bs);
}
