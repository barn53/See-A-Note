
import UIKit


var i: Int!
var k: Int?

if let i = i {
    i
}

if let k = k {
    k
}

i = 1
k = 1

print(i)
print(k)

i
k

var ii: [(Int, String)] = [(1,"ä"),(3,"ö"),(4,"ü")]

ii = ii.filter({$0.0 != 1})
ii


9 % 7

let okt = 7
let line = -1

(line+2*okt) % okt
(line+okt) % okt
line % okt
((line-okt) % okt)+okt
((line-2*okt) % okt)+okt
