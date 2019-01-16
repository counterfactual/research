const Trie = require('merkle-patricia-tree/secure');
const levelup = require('levelup');
const leveldown = require('leveldown');
const utils = require('ethereumjs-util');
const BN = utils.BN;
const Account = require('ethereumjs-account');

const db = levelup(leveldown('/Users/xuanji/Library/Ethereum/geth/chaindata'));

// Genesis block state root
const stateRoot = '0xd7f8974fb5ac78d9ac099b9ad5018bedc2ce0a72dad1827a1709da30580f0544';

const trie = new Trie(db, stateRoot);

const dump = (address) => {
  trie.get(address, function (err, raw) {
    if (err) return cb(err);
    const account = new Account(raw);
    console.log({
      'raw': raw.toString('hex'),
      'decoded': account.toJSON(),
    });
  });
}

dump("0x3282791d6fd713f1e94f4bfd565eaa78b3a0599d");
dump("0x17961d633bcf20a7b029a7d94b7df4da2ec5427f");
