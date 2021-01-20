import time

import multem
import multem.crystalline_materials


def run():

    system_conf = multem.System_Configuration()
    system_conf.precision = "float"
    system_conf.device = "device"
    system_conf.cpu_nthread = 4
    system_conf.gpu_device = 0

    input_multem = multem.Input_Multislice(system_conf)

    input_multem.simulation_type = "EELS"
    input_multem.pn_model = "Still_Atom"
    input_multem.interaction_model = "Multislice"
    input_multem.potential_slicing = "Planes"
    input_multem.potential_type = "Lobato_0_12"

    input_multem.pn_dim = (1, 1, 0)
    input_multem.pn_seed = 300183
    input_multem.pn_single_conf = 0
    input_multem.pn_nconf = 5

    input_multem.bwl = 0

    input_multem.E_0 = 300
    input_multem.theta = 0.0
    input_multem.phi = 0.0

    na = 4
    nb = 4
    nc = 10
    ncu = 2
    rmsd_3d = 0.085

    [
        input_multem.spec_atoms,
        input_multem.spec_lx,
        input_multem.spec_ly,
        input_multem.spec_lz,
        a,
        b,
        c,
        input_multem.spec_dz,
    ] = multem.crystalline_materials.SrTiO3001_xtl(na, nb, nc, ncu, rmsd_3d)

    input_multem.nx = 512
    input_multem.ny = 512

    input_multem.iw_type = 4
    input_multem.iw_psi = [0]
    input_multem.iw_x = [input_multem.spec_lx / 2]
    input_multem.iw_y = [input_multem.spec_ly / 2]

    input_multem.cond_lens_m = 0
    input_multem.cond_lens_c_10 = 88.7414
    input_multem.cond_lens_c_30 = 0.04
    input_multem.cond_lens_c_50 = 0.00
    input_multem.cond_lens_c_12 = 0.0
    input_multem.cond_lens_phi_12 = 0.0
    input_multem.cond_lens_c_23 = 0.0
    input_multem.cond_lens_phi_23 = 0.0
    input_multem.cond_lens_inner_aper_ang = 0.0
    input_multem.cond_lens_outer_aper_ang = 21.0
    input_multem.cond_lens_ti_sigma = 32
    input_multem.cond_lens_ti_npts = 10
    input_multem.cond_lens_si_sigma = 0.2
    input_multem.cond_lens_si_rad_npts = 8

    input_multem.scanning_type = "Line"
    input_multem.scanning_periodic = 1
    input_multem.scanning_ns = 10
    input_multem.scanning_x0 = 2 * a
    input_multem.scanning_y0 = 2.5 * b
    input_multem.scanning_xe = 3 * a
    input_multem.scanning_ye = 2.5 * b

    input_multem.eels_E_loss = 532
    input_multem.eels_m_selection = 3
    input_multem.eels_channelling_type = 1
    input_multem.eels_collection_angle = 100
    input_multem.eels_Z = 8

    input_multem.eels_E_loss = 456
    input_multem.eels_m_selection = 3
    input_multem.eels_channelling_type = 1
    input_multem.eels_collection_angle = 100
    input_multem.eels_Z = 22

    input_multem.eels_E_loss = 1940
    input_multem.eels_m_selection = 3
    input_multem.eels_channelling_type = 1
    input_multem.eels_collection_angle = 100
    input_multem.eels_Z = 38

    st = time.perf_counter()
    output_multislice = multem.tem_simulation(input_multem)
    print("Time: %.4f seconds" % (time.perf_counter() - st))


if __name__ == "__main__":
    run()
