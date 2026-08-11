declare module 'idiomorph' {
    export type MorphStyle = 'outerHTML' | 'innerHTML';
    export type HeadStyle = 'merge' | 'append' | 'morph' | 'none';

    export interface IdiomorphCallbacks {
        beforeNodeAdded?: (node: Node) => boolean | void;
        afterNodeAdded?: (node: Node) => void;
        beforeNodeMorphed?: (oldNode: Node, newNode: Node) => boolean | void;
        afterNodeMorphed?: (oldNode: Node, newNode: Node) => void;
        beforeNodeRemoved?: (node: Node) => boolean | void;
        afterNodeRemoved?: (node: Node) => void;
        beforeAttributeUpdated?: (
        attributeName: string,
        node: Element,
        mutationType: 'update' | 'remove'
        ) => boolean | void;
    }

    export interface IdiomorphHeadConfig {
        style?: HeadStyle;
        block?: boolean;
        ignore?: boolean;
        callbacks?: IdiomorphCallbacks;
    }

    export interface IdiomorphOptions {
        morphStyle?: MorphStyle;
        ignoreActive?: boolean;
        ignoreActiveValue?: boolean;
        restoreFocus?: boolean;
        head?: IdiomorphHeadConfig;
        callbacks?: IdiomorphCallbacks;
    }

    export interface Idiomorph {
        morph: (
        oldNode: Element | Document,
        newNode: Element | Document | string,
        config?: IdiomorphOptions
        ) => Element[] | Node[] | null;
        defaults: IdiomorphOptions;
    }

    export const Idiomorph: Idiomorph;
    export default Idiomorph;
}