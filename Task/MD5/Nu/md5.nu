[
  '' 'a' 'abc' 'message digest'
  'abcdefghijklmnopqrstuvwxyz'
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  '12345678901234567890123456789012345678901234567890123456789012345678901234567890'
]
| each { hash md5 }
