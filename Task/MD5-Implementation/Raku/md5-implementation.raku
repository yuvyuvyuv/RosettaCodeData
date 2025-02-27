proto md5($msg) returns Blob is export {*}
multi md5(Str $msg) { md5 $msg.encode }
multi md5(Blob $msg) {
  [~] map { buf8.new.write-uint32: 0, $_, LittleEndian },
    |reduce -> Blob $blob, blob32 $X {
      blob32.new: $blob Z+
        reduce -> $b, $i {
          blob32.new:
            $b[3],
            $b[1] +
              -> uint32 \x, \n { (x +< n) +| (x +> (32-n)) }(
              ($b[0] + (BEGIN Array.new:
              { ($^x +& $^y) +| (+^$x +& $^z) },
              { ($^x +& $^z) +| ($^y +& +^$z) },
              { $^x +^ $^y +^ $^z },
              { $^y +^ ($^x +| +^$^z) }
              )[$i div 16](|$b[1..3]) +
              (BEGIN blob32.new: map &floor ∘ * * 2**32 ∘ &abs ∘ &sin ∘ * + 1, ^64)[$i] +
              $X[(BEGIN Blob.new: 16 X[R%] flat ($++, 5*$++ + 1, 3*$++ + 5, 7*$++) Xxx 16)[$i]]
              ) mod 2**32,
              (BEGIN flat < 7 12 17 22 5 9 14 20 4 11 16 23 6 10 15 21 >.rotor(4) Xxx 4)[$i]
            ),
            $b[1],
            $b[2]
        }, $blob, |^64;
    },
    (BEGIN blob32.new: 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476),
    |map { blob32.new: @$_ },
      {
        $^b.push(blob8.new(@$_).read-uint32(0)) for (@$msg, 0x80, 0x00 xx (-($msg.elems + 1 + 8) % 64))
            .flat.rotor(4);
        $b.write-uint64: $b.elems, 8*$msg.elems, LittleEndian;
        $b;
      }(buf32.new)
    .rotor(16);
}

CHECK {
  use Test;

  for 'd41d8cd98f00b204e9800998ecf8427e', '',
      '0cc175b9c0f1b6a831c399e269772661', 'a',
      '900150983cd24fb0d6963f7d28e17f72', 'abc',
      'f96b697d7cb7938d525a2f31aaf161d0', 'message digest',
      'c3fcd3d76192e4007dfb496cca67e13b', 'abcdefghijklmnopqrstuvwxyz',
      'd174ab98d277d9f5a5611c2c9f419d9f', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
      '57edf4a22be3c955ac49da2e2107b67a', '12345678901234567890123456789012345678901234567890123456789012345678901234567890'
        -> $expected, $msg {
          my $digest = md5($msg).list».fmt('%02x').join;
          is($digest, $expected, "$digest is MD5 digest of '$msg'");
        }
  done-testing;
}
