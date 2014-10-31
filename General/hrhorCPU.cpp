#include "hmathCPU.h"
#include <cstring>
#include "hConstTypes.h"
#include "hrhorCPU.h"

// Constructor
crhorCPU::crhorCPU(){
	PotPar = 0;
	cl = cnl = 0;
}

// Destructor
crhorCPU::~crhorCPU(){
	PotPar = 0;
	cl = cnl = 0;
}

// Set Atom type
void crhorCPU::SetAtomT(int PotPari, sAtomTypesCPU AtomTypesCPUi){
	PotPar = PotPari;
	std::memcpy(&AtomTypesCPU, &AtomTypesCPUi, sizeof(sAtomTypesCPU));
}

// 3D electron density (Pr, dPr) where dPr is the first derivative along r
void crhorCPU::rhor(double r, double &f, double &df){
	int i;
	ir = 1.0/r; r2 = r*r;
	f = df = 0.0;
	switch (PotPar){
		case 1:
			// 1: Doyle and Turner parameterization - 4 Gaussians - [0, 4]
			for (i=0; i<4; i++){
				cl = AtomTypesCPU.cPr.cl[i]; cnl = AtomTypesCPU.cPr.cnl[i];
				ft = cl*exp(-cnl*r2);
				f += (2.0*r2 - 3.0/cnl)*ft;
				df += (2.0*cnl*r2 - 5.0)*ft;
			}
			df = -2.0*r*df;
			break;
		case 2:
			// 2: Peng et al. parameterization - 5 Gaussians - [0, 4]
			for (i=0; i<5; i++){
				cl = AtomTypesCPU.cPr.cl[i]; cnl = AtomTypesCPU.cPr.cnl[i];
				ft = cl*exp(-cnl*r2);
				f += (2.0*r2 - 3.0/cnl)*ft;
				df += (2.0*cnl*r2 - 5.0)*ft;
			}
			df = -2.0*r*df;
			break;
		case 3:
			// 3: Peng et al. parameterization - 5 Gaussians - [0, 12]
			for (i=0; i<5; i++){
				cl = AtomTypesCPU.cPr.cl[i]; cnl = AtomTypesCPU.cPr.cnl[i];
				ft = cl*exp(-cnl*r2);
				f += (2.0*r2 - 3.0/cnl)*ft;
				df += (2.0*cnl*r2 - 5.0)*ft;
			}
			df = -2.0*r*df;
			break;
		case 4:
			// 4: Kirkland parameterization - 3 Yukawa + 3 Gaussians - [0, 12]			
			for (i=0; i<3;i++){
				cl = AtomTypesCPU.cPr.cl[i]; cnl = AtomTypesCPU.cPr.cnl[i];
				f += ft = cl*exp(-cnl*r)*ir;
				df += -(cnl + ir)*ft;
			}

			for (i=3; i<6; i++){
				cl = AtomTypesCPU.cPr.cl[i]; cnl = AtomTypesCPU.cPr.cnl[i];
				ft = cl*exp(-cnl*r2);
				f += (2.0*r2 - 3.0/cnl)*ft;
				df += -2.0*r*(2.0*cnl*r2 - 5.0)*ft;
			}
			break;
		case 5:
			// 5: Weickenmeier and H.Kohl - a*(1-exp(-bg^2)/g^2 - [0, 12]
			for (i=0; i<6; i++){
				cl = AtomTypesCPU.cPr.cl[i]; cnl = AtomTypesCPU.cPr.cnl[i];
				f += ft = cl*exp(-cnl*r2);
				df += cnl*ft;
			}
			df = -2.0*r*df;
			break;
		case 6:
			// 6: Lobato parameterization - 5 Hydrogen fe - [0, 12]
			for (i=0; i<5; i++){
				cl = AtomTypesCPU.cPr.cl[i]; cnl = AtomTypesCPU.cPr.cnl[i];
				f += ft = cl*exp(-cnl*r);
				df += -cnl*ft;
			}
			break;
	}
}

/************************************************************************************/
// 3D electron scattering factors calculation (feg, dfeg) where dfeg is the first derivative along g
void crhorCPU::rhor(int nr, double *r, double *f, double *df){
	for (int i=0; i<nr; i++)
		rhor(r[i], f[i], df[i]);
}