const RLP = require('rlp');
const assert = require('assert');

const nestedList = [
    Buffer.from('', 'hex'),
    Buffer.from('487a9a304539440000', 'hex'),
    Buffer.from('56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421', 'hex'),
    Buffer.from('c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470', 'hex')
];

const encoded = RLP.encode(nestedList);

console.log(encoded.toString('hex'));
