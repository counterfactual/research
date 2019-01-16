#!./venv/bin/python3

from charm.toolbox.pairinggroup import PairingGroup,ZR,G1,G2,GT,pair

def irange(a, b):
    return range(a, b+1)

group = PairingGroup('BN254')
_G = group.hash("G", G1)
_H = group.hash("H", G2)

def generate_crs(G, H, d):
    crs_g = {
        (0,0,0): G(0,0,0),
        (1,0,0): G(1,0,0),
        (0,0,1): G(0,0,1),
    }

    for i in irange(0, 2*d):
        for j in irange(1, 12):
            if j == 7: continue
            crs_g[(i,j,0)] = G(i,j,0)

    for i in irange(0, 2*d):
        for j in irange(1, 6):
            for k in irange(1, 3*d):
                if (i,j) == (d,4): continue
                crs_g[(i,j,k)] = G(i,j,k)

    for i in irange(0, d):
        for j in irange(1, 4):
            crs_g[(i,j,6*d)] = G(i,j,6*d)

    crs_h = {
        (0,0,0): H(0,0,0),
        (1,0,0): H(1,0,0),
    }

    for i in irange(0,d):
        for j in irange(1,6):
            crs_h[(i,j,0)] = H(i,j,0)

    for i in irange(0, d):
        for j in irange(0, 2):
            for k in irange(1, 3*d):
                crs_h[(i,j,k)] = H(i,j,k)

    crs_h[(0,0,6*d)] = H(0,0,6*d)

    return {'g': crs_g, 'h': crs_h}


def setup(d):
    x = group.hash("x", ZR)
    y = group.hash("y", ZR)
    z = group.hash("z", ZR)

    rho = (_G**x, _G**y, _G**z, _G**x, _G**y, _G**z, _H**x, _H**y, _H**z,)

    def G(i,j,k):
        return _G**(x**i * y**j * z**k)

    def H(i,j,k):
        return _H**(x**i * y**j * z**k)

    return (rho, generate_crs(G, H, d))

def update(crs, d):
    alpha = group.hash("alpha", ZR)
    beta = group.hash("beta", ZR)
    gamma = group.hash("gamma", ZR)

    def G(i, j, k):
        return crs['g'][i,j,k]**(alpha**i * beta**j * gamma**k)

    def H(i, j, k):
        return crs['h'][i,j,k]**(alpha**i * beta**j * gamma**k)

    rho = (G(1,0,0), G(0,1,0), G(0,0,1), _G**alpha, _G**beta, _G**gamma, _H**alpha, _H**beta, _H**gamma)

    return (rho, generate_crs(G, H, d))

def verify_crs(crs, d):
    def G(i,j,k):
        return crs['g'][i,j,k]
    def H(i,j,k):
        return crs['h'][i,j,k]

    def assert_pairing(a,b,c,d,e,f,g,h,i,j,k,l):
        assert(
            group.pair_prod(G(a,b,c), H(d,e,f)) ==
            group.pair_prod(G(g,h,i), H(j,k,l)))

    # assert the exponents supposed to be yj are correct
    for j in irange(1,6):
        assert_pairing(0,j,0,0,0,0,0,0,0,0,j,0)
    for j in irange(1,5):
        assert_pairing(0,0,0,0,j+1,0,0,1,0,0,j,0)
    for j in irange(8,12):
        assert_pairing(0,j,0,0,0,0,0,6,0,0,j-6,0)

    # assert the exponents supposed to be xi yj are correct
    assert_pairing(1,0,0,0,0,0,0,0,0,1,0,0)
    for i in irange(1,d):
        for j in irange(1,6):
            assert_pairing(i,j,0,0,0,0,i-1,j,0,1,0,0)
        for j in irange(8,12):
            assert_pairing(i,j,0,0,0,0,i-1,j,0,1,0,0)

    for i in irange(1,d):
        for j in irange(1,6):
            assert_pairing(i,j,0,0,0,0,0,0,0,i,j,0)

    # assert the exponents supposed to be xi yj zk are correct
    assert_pairing(0,0,1,0,0,0,0,0,0,0,0,1)
    for k in irange(1,3*d):
        assert_pairing(0,1,k,0,0,0,0,1,0,0,0,k)
    for i in irange(0,d):
        for j in irange(0,2):
            for k in irange(1,3*d):
                if (i,j) == (d,0): continue # TODO: REMOVE
                assert_pairing(i,j,0,0,0,k,0,0,0,i,j,k)

    for i in irange(0,d):
        for j in irange(1,6):
            for k in irange(1,3*d):
                if (i,j) == (d,4): continue
                assert_pairing(i,j,k,0,0,0,i,j,0,0,0,k)
    for i in irange(d+1,2*d):
        for j in irange(1,6):
            for k in irange(1,3*d):
                continue # TODO: REMOVE
                assert_pairing(i,j,k,0,0,0,i-d,0,k,d,j,0)

    assert_pairing(0,1,3*d,0,0,3*d,0,1,0,0,0,6*d)

    for i in irange(0,d):
        for j in irange(1,4):
            assert_pairing(i,j,0,0,0,6*d,i,j,6*d,0,0,0)

def verify_initial_rho(rho_0):
    pass

def verify_consecutive_rhos(rhoi, rhoj):
    # rhoi = rho_i
    # rhoj = rho_{i-1}

    A_i, B_i, C_i, Ab_i, Bb_i, Cb_i, Ah_i, Bh_i, Ch_i = rhoi
    A_j, B_j, C_j, Ab_j, Bb_j, Cb_j, Ah_j, Bh_j, Ch_j = rhoj

    assert(
        group.pair_prod(A_i, _H) ==
        group.pair_prod(A_j, Ah_i))
    assert(
        group.pair_prod(B_i, _H) ==
        group.pair_prod(B_j, Bh_i))
    assert(
        group.pair_prod(C_i, _H) ==
        group.pair_prod(C_j, Ch_i))

def verify_final_rho(rho):
    A, B, C, Ab, Bb, Cb, Ah, Bh, Ch = rho
    assert(
        group.pair_prod(Ab, _H) ==
        group.pair_prod(_G, Ah))
    assert(
        group.pair_prod(Bb, _H) ==
        group.pair_prod(_G, Bh))
    assert(
        group.pair_prod(Cb, _H) ==
        group.pair_prod(_G, Ch))

rho_0, crs_0 = setup(d=2)
rho_1, crs_1 = update(crs_0, d=2)
rho_2, crs_2 = update(crs_1, d=2)

verify_crs(crs_0, d=2)
verify_crs(crs_1, d=2)
verify_crs(crs_2, d=2)

verify_consecutive_rhos(rho_2, rho_1)
verify_final_rho(rho_2)
