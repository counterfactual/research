const Trie = require('merkle-patricia-tree');
const levelup = require('levelup');
const memdown = require('memdown');
const fs = require('fs');
const RLP = require('rlp');
const util = require('util');

const db = levelup(memdown());

trie = new Trie(db);

const bytesFromStr = (str) => {
    var data = [];
    for (var i = 0; i < str.length; i++){
        data.push(str.charCodeAt(i));
    }
    return Buffer.from(data);
}

const ops = [
    ['646f', 'verb'],
].map(([key, value]) => {
    return {
        'type': 'put',
        'key': Buffer.from(key, 'hex'),
        'value': bytesFromStr(value)
    }
});

trie.batch(ops, function() {
    console.log(trie.root.toString('hex'));
    db.createReadStream()
      .on('data', function (data) {
        console.log(data.key);
        console.log(
            util.inspect(RLP.decode(data.value), true, 10)
        );
      })
      .on('error', function (err) {
        console.log('Oh my!', err)
      })
      .on('close', function () {
        console.log('Stream closed')
      })
      .on('end', function () {
        console.log('Stream ended')
      })
});
