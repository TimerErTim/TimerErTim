export function mergeRefs<T>(...refs: Array<React.Ref<T> | undefined | null>) {
    return (node: T | null) => {
      refs.forEach((ref) => {
        if (typeof ref === 'function') {
          ref(node);
        } else if (ref != null) {
          ref.current = node;
        }
      });
    };
  };