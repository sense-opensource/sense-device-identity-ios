import Foundation

func murmurHash3_x64_128(input: String, seed: UInt64 = 0) -> String {
    let data = Array(input.utf8)
    let length = data.count
    let nblocks = length / 16

    var h1: UInt64 = seed
    var h2: UInt64 = seed

    let c1: UInt64 = 0x87c37b91114253d5
    let c2: UInt64 = 0x4cf5ad432745937f

    // body
    for i in 0..<nblocks {
        let i16 = i * 16

        let block1 = data[i16..<i16+8]
        let block2 = data[i16+8..<i16+16]

        let k1 = block1.withUnsafeBytes { $0.load(as: UInt64.self).littleEndian }
        let k2 = block2.withUnsafeBytes { $0.load(as: UInt64.self).littleEndian }

        var k1m = k1
        var k2m = k2

        k1m &*= c1
        k1m = (k1m << 31) | (k1m >> (64 - 31))
        k1m &*= c2
        h1 ^= k1m

        h1 = (h1 << 27) | (h1 >> (64 - 27))
        h1 &+= h2
        h1 = h1 &* 5 &+ 0x52dce729

        k2m &*= c2
        k2m = (k2m << 33) | (k2m >> (64 - 33))
        k2m &*= c1
        h2 ^= k2m

        h2 = (h2 << 31) | (h2 >> (64 - 31))
        h2 &+= h1
        h2 = h2 &* 5 &+ 0x38495ab5
    }

    // tail
    let tail = data[nblocks * 16..<length]
    var k1: UInt64 = 0
    var k2: UInt64 = 0

    for i in 0..<tail.count {
        let byte = UInt64(tail[tail.index(tail.startIndex, offsetBy: i)])
        let shift = UInt64((i % 8) * 8)
        if i < 8 {
            k1 |= byte << shift
        } else {
            k2 |= byte << shift
        }
    }

    if tail.count > 0 {
        k1 &*= c1
        k1 = (k1 << 31) | (k1 >> (64 - 31))
        k1 &*= c2
        h1 ^= k1

        k2 &*= c2
        k2 = (k2 << 33) | (k2 >> (64 - 33))
        k2 &*= c1
        h2 ^= k2
    }

    // finalization
    h1 ^= UInt64(length)
    h2 ^= UInt64(length)

    h1 &+= h2
    h2 &+= h1

    h1 = fmix64(h1)
    h2 = fmix64(h2)

    h1 &+= h2
    h2 &+= h1

    // Format into 128-bit hex string with hyphens every 8 chars
    let hexString = String(format: "%016llx%016llx", h1, h2)
    let chunks = stride(from: 0, to: hexString.count, by: 8).map {
        let start = hexString.index(hexString.startIndex, offsetBy: $0)
        let end = hexString.index(start, offsetBy: 8, limitedBy: hexString.endIndex) ?? hexString.endIndex
        return String(hexString[start..<end])
    }
    return chunks.joined(separator: "-")
}

private func fmix64(_ kInit: UInt64) -> UInt64 {
    var k = kInit
    k ^= k >> 33
    k &*= 0xff51afd7ed558ccd
    k ^= k >> 33
    k &*= 0xc4ceb9fe1a85ec53
    k ^= k >> 33
    return k
}
