#include "hmathCPU.h"
#include <cstring>
#include "hConstTypes.h"
#include "hfxgCPU.h"

// Constructor
cfxgCPU::cfxgCPU(){
	PotPar = 0;
	cl = cnl = 0;
}

// Destructor
cfxgCPU::~cfxgCPU(){
	PotPar = 0;
	cl = cnl = 0;
}

// Set Atom type
void cfxgCPU::SetAtomT(int PotPari, sAtomTypesCPU AtomTypesCPUi){
	PotPar = PotPari;
	std::memcpy(&AtomTypesCPU, &AtomTypesCPUi, sizeof(sAtomTypesCPU));
}

// x-ray scattering factor(fx, dfx) where dfx is the first derivative along g
void cfxgCPU::fxg(double g, double &f, double &df){
	int i;
	g2 = g*g;
	f = df = 0.0;
	switch (PotPar){
		case 1:
			// 1: Doyle and Tugner pagametegization - 4 Gaussians - [0, 4]
			for (i=0; i<4; i++){
				cl = AtomTypesCPU.cfxg.cl[i]; cnl = AtomTypesCPU.cfxg.cnl[i];
				f += ft = cl*exp(-cnl*g2);
				df += ft*(1.0-cnl*g2);
			}
			f = AtomTypesCPU.Z - g2*f;
			df = -2.0*g*df;
			break;
		case 2:
			// 2: Peng et al. parameterization - 5 Gaussians - [0, 4]
			for (i=0; i<5; i++){
				cl = AtomTypesCPU.cfxg.cl[i]; cnl = AtomTypesCPU.cfxg.cnl[i];
				f += ft = cl*exp(-cnl*g2);
				df += ft*(1.0-cnl*g2);
			}
			f = AtomTypesCPU.Z - g2*f;
			df = -2.0*g*df;
			break;
		case 3:
			// 3: Peng et al. parameterization - 5 Gaussians - [0, 12]
			for (i=0; i<5; i++){
				cl = AtomTypesCPU.cfxg.cl[i]; cnl = AtomTypesCPU.cfxg.cnl[i];
				f += ft = cl*exp(-cnl*g2);
				df += ft*(1.0-cnl*g2);
			}
			f = AtomTypesCPU.Z - g2*f;
			df = -2.0*g*df;
			break;
		case 4:
			// 4: Kirkland parameterization - 3 Yukawa + 3 Gaussians - [0, 12]					
			for (i=0; i<3;i++){
				cl = AtomTypesCPU.cfxg.cl[i]; cnl = AtomTypesCPU.cfxg.cnl[i];
				t = 1.0/(cnl + g2);
				f += ft = cl*t;
				df += ft*cnl*t;
			}

			for (i=3; i<6; i++){
				cl = AtomTypesCPU.cfxg.cl[i]; cnl = AtomTypesCPU.cfxg.cnl[i];
				f += ft = cl*exp(-cnl*g2);
				df += ft*(1.0-cnl*g2);
			}
			f = AtomTypesCPU.Z - g2*f;
			df = -2.0*g*df;
			break;
		case 5:
			// 5: Weickenmeier and H.Kohl - a*(1-exp(-bg^2)/g^2 - [0, 12]
			for (i=0; i<6;i++){
				cl = AtomTypesCPU.cfxg.cl[i]; cnl = AtomTypesCPU.cfxg.cnl[i];
				f += ft = cl*exp(-cnl*g2);
				df += cnl*ft;
			}
			df = -2.0*g*df;
			break;
		case 6:
			// 6: Lobato parameterization - 5 Hydrogen fe - [0, 12]
			for (i=0; i<5; i++){
				cl = AtomTypesCPU.cfxg.cl[i]; cnl = AtomTypesCPU.cfxg.cnl[i];
				t = 1.0/(1.0+cnl*g2);
				f += ft = cl*t*t;
				df += cnl*ft*t;
			}
			df = -4.0*g*df;
			break;
	}
}

/************************************************************************************/
// 3D electron scattering factors calculation (feg, dfeg) where dfeg is the first derivative along g
void cfxgCPU::fxg(int ng, double *g, double *f, double *df){
	for (int i=0; i<ng; i++)
		fxg(g[i], f[i], df[i]);
}