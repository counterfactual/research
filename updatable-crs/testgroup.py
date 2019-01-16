#!./venv/bin/python3

from charm.toolbox.pairinggroup import PairingGroup,G1

print(PairingGroup('BN254').hash("G", G1))
