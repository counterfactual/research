/*
This file reads derived_data/genesis_state_kvp (account => balance, nonce, storage root, code) and computes the trie root
*/

const Trie = require('merkle-patricia-tree');
const levelup = require('levelup');
const memdown = require('memdown');
const fs = require('fs');

const db = levelup(memdown());

trie = new Trie(db);

const genesis_state_kvp = fs.readFileSync('../derived_data/genesis_state_kvp', 'utf8');

const ops = genesis_state_kvp.split('\n').filter(line => line.length > 0).map(line => {
    const [key, value] = line.split(' ');
    return {
        'type': 'put',
        'key': Buffer.from(key, 'hex'),
        'value': Buffer.from(value, 'hex'),
    }
});

trie.batch(ops, function() {
    console.log(trie.root.toString('hex'));
});
