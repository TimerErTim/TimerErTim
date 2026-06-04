import xdelta3


def test_encode_decode_roundtrip():
    source = b"Hello, world!"
    target = b"Hello, world! Hello, world!"

    patch = xdelta3.encode(target, source)
    assert isinstance(patch, bytes)
    assert len(patch) > 0

    restored = xdelta3.decode(patch, source)
    assert restored == target


def test_docs_rs_example():
    source = bytes([1, 2, 4, 4, 7, 6, 7])
    target = bytes([1, 2, 3, 4, 5, 6, 7])
    patch = bytes(
        [
            214,
            195,
            196,
            0,
            0,
            0,
            13,
            7,
            0,
            7,
            1,
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
        ]
    )

    restored = xdelta3.decode(patch, source)
    assert restored == target

    regenerated = xdelta3.encode(target, source)
    assert xdelta3.decode(regenerated, source) == target
