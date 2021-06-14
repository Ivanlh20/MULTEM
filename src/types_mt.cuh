/*
 * This file is part of Multem.
 * Copyright 2021 Ivan Lobato <Ivanlh20@gmail.com>
 *
 * Multem is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version of the License, or
 * (at your option) any later version.
 *
 * Multem is distributed in the hope that it will be useful, 
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Multem. If not, see <http:// www.gnu.org/licenses/>.
 */

#ifndef TYPES_MT_H
	#define TYPES_MT_H

	#ifdef _MSC_VER
		#pragma once
	#endif 

	#include <type_traits>
	#include <vector>
	#include <algorithm>
	#include <thread>
	#include <mutex>
	#include <utility>
	#include <functional> 

	#include "const_enum_mt.cuh"
	#include "math.cuh"
	#include "type_traits_gen.cuh"
	#include "cgpu_fcns_gen.cuh"
	#include "r_2d.cuh"
	#include "r_3d.cuh"
	#include "particles.cuh"
	#include "types.cuh"

	namespace mt
	{
		/************************* beam position 2d **************************/
		template <class T>
		struct Beam_Pos_2d
		{
			Vctr<dt_int32, edev_cpu> idx;		// index
			Vctr<R_2d<T>, edev_cpu> p;			// xy-position 

			Beam_Pos_2d() {}

			Beam_Pos_2d(dt_int32 new_size) { resize(new_size); }

			template <class TVctr>
			void set_in_data(const TVctr& x) 
			{ 
				dt_int32 n = x.cols;
				resize(n);
				for(auto ik = 0; ik<n; ik++)
				{
					idx[ik] = ik;
					p[ik] = R_2d<T>(x(0, ik), x(1, ik));
				}
			}

			template <class TVctr>
			void set_in_data(const TVctr& x, const TVctr& y) 
			{
				dt_int32 n = min(x.size(), y.size());
				resize(n);
				for(auto ik = 0; ik<n; ik++)
				{
					idx[ik] = ik;
					p[ik] = R_2d<T>(x[ik], y[ik]);
				}
			}

			typename Vctr<R_2d<T>, edev_cpu>::iterator begin() const 
			{ 
				return p.begin();
			}

			typename Vctr<R_2d<T>, edev_cpu>::iterator end() const 
			{ 
				return p.end();
			}

			dt_int32 size() const { return idx.size(); }

			void resize(dt_int32 new_size)
			{
				idx.resize(new_size);
				p.resize(new_size);
			}

			void init()
			{
				thrust::fill(idx.begin(), idx.end(), 0);
				thrust::fill(p.begin(), p.end(), R_2d<T>());
			}

			void clear()
			{
				idx.clear();
				p.clear();
			}

			void shrink_to_fit()
			{
				idx.shrink_to_fit();
				p.shrink_to_fit();
			}

			void clear_shrink_to_fit()
			{
				clear();
				shrink_to_fit();
			}

			Vctr<T, edev_cpu> x()
			{
				Vctr<T, edev_cpu> x;
				x.reserve(p.size());
				for(auto ik = 0; ik<p.size(); ik++)
				{
					x.push_back(p[ik].x);
				}

				return x;
			}

			Vctr<T, edev_cpu> y()
			{
				Vctr<T, edev_cpu> y;
				y.reserve(p.size());
				for(auto ik = 0; ik<p.size(); ik++)
				{
					y.push_back(p[ik].y);
				}

				return y;
			}

			template <class TBeam_Pos_2d>
			void assign(TBeam_Pos_2d &beam_pos)
			{
				resize(beam_pos.size());
				thrust::copy(beam_pos.idx.begin(), beam_pos.idx.end(), idx.begin());
				thrust::copy(beam_pos.p.begin(), beam_pos.p.end(), p.begin());
			}

			template <class TBeam_Pos_2d>
			Beam_Pos_2d<T>& operator=(const TBeam_Pos_2d &beam_pos)
			{
			 assign(beam_pos);
			 return *this;
			}
		};

		/******************* spec layer information *********************/
		template <class T>
		class Spec_Lay_Info
		{
			public:
				R_3d<T> bs;				// box size
				R_3d<T> r_0;			// initial position
				dt_int32 region;		// region
				eSpec_Lay_Typ type;		// specimen layer type
				T sli_thk;				// Slice thickness

				Spec_Lay_Info(): bs(), r_0(), region(c_dflt_region), type(eSLT_none), sli_thk(2) {};

				Spec_Lay_Info(const R_3d<T>& bs, R_3d<T> r_0 = R_3d<T>(), dt_int32 region = c_dflt_region, 
				eSpec_Lay_Typ type = eSLT_none, T sli_thk = 2.0): bs(bs), r_0(r_0), region(region), type(type), sli_thk(sli_thk) {};

				Spec_Lay_Info<T>& operator=(Spec_Lay_Info<T> &spec_lay_info)
				{
					if (this != &ptc_s)
					{
						bs = spec_lay_info.bs;
						r_0 = spec_lay_info.r_0;
						sli_thk = spec_lay_info.sli_thk;
						region = spec_lay_info.region;
						type = spec_lay_info.type;
					}

					return *this;
				}

				template <class U> 
				Spec_Lay_Info<T>& operator=(Spec_Lay_Info<U> &spec_lay_info)
				{
					assign(spec_lay_info);
			
					return *this;
				}

				template <class U> 
				void assign(const Spec_Lay_Info<U>& spec_lay_info)
				{ 
					if ((void*)this != (void*)&spec_lay_info)
					{
						bs = spec_lay_info.bs;
						r_0 = spec_lay_info.r_0;
						r_e = spec_lay_info.r_e;
						sli_thk = T(spec_lay_info.sli_thk);
						region = spec_lay_info.region;
						type = spec_lay_info.type;
					}
				}

				dt_bool is_spec_lay_top() const 
				{ 
					return is_spec_lay_top(type); 
				};

				dt_bool is_spec_lay_bottom() const 
				{ 
					return is_spec_lay_bottom(type); 
				};

				dt_bool is_spec_lay_middle() const 
				{ 
					return is_spec_lay_middle(type); 
				};

				dt_bool is_spec_lay_user_def() const 
				{ 
					return is_spec_lay_user_def(type); 
				};

				void set_region(Ptc_Atom<T>& atoms)
				{
					if (bs.z<1e-4)
					{
						region = 0;
						return;
					}

					dt_int32 f_region = 0;
					dt_int32 c_region = 0;
					for(auto iatoms = 0; iatoms < atoms.size(); iatoms++)
					{
						auto z = atoms.z[iatoms];
						if ((z_0<r.z) && (z<r.z_e))
						{
							f_region += atoms.region[iatoms];
							c_region++;
						}
					}
					c_region = max(1, c_region);
					region = static_cast<dt_int32>(::round(T(f_region)/T(c_region)));
				}															
		};
		
		template <class T>
		using Vctr_Spec_Lay_Info = Vctr_std<Spec_Lay_Info<T>>;

		/************************* slice thickness ***************************/
		template <class T>
		struct Slice
		{
			Slice(): z_0(0), z_e(0), z_int_0(0), 
			z_int_e(0), iatom_0(1), iatom_e(0), ithk(-1) {}

			T z_0;		// Initial z-position
			T z_e;		// Final z-position
			T z_int_0;		// Initial z-position
			T z_int_e;		// Final z-position
			dt_int32 iatom_0;		// Index to initial z-position
			dt_int32 iatom_e;		// Index to final z-position
			dt_int32 ithk;		// thick index

			T sli_thk() const { return fabs(z_e-z_0); }

			T z_m() const { return 0.5*(z_e+z_0); }
		};

		/**************************** thickness ******************************/
		template <class T>
		struct Thick
		{
			Thick(): z(0), z_zero_def_plane(0), z_back_prop(0), 
			islice(0), iatom_e(0) {}

			T z;		// z
			T z_zero_def_plane;		// z: Zero defocus
			T z_back_prop;		// z: Back propagation

			dt_int32 islice;		// slice position
			dt_int32 iatom_e;		// Last atom index
		};

		/*************************** identify planes *************************/
		template <class T>
		struct Identify_Planes
		{
			using TVctr = Vctr<T, edev_cpu>;
			using TVctr_I = Vctr<dt_int32, edev_cpu>;

			public:
				Identify_Planes(): dv(0.1) {}

				// Identify planes: Require v to be sorted
				TVctr operator()(TVctr& v)
				{
					TVctr v_plane;

					if (v.size()==0)
					{
						return v_plane;
					}

					// min and max element
					T v_min = v.front();
					T v_max = v.back();

					// calculate hist and correct it
					auto v_hist = fcn_hist(v, dv, v_min, v_max);

					if (v_hist.size()==1)
					{
						v_plane.push_back(thrust::reduce(v.begin(), v.end())/T(v.size()));
						return v_plane;
					}

					// calculate layer limits
					TVctr v_lim;
					v_lim.reserve(v_hist.size());

					for(auto iz = 0; iz < v_hist.size()-1; iz++)
					{
						if ((v_hist[iz]>0) && (v_hist[iz+1]==0))
						{
							v_lim.push_back(v.front()+(iz+1)*dv);
						}
					}
					v_lim.push_back(v.back()+dv);

					// calculate planes
					v_plane.reserve(v_lim.size());

					T v_m = v.front();
					T v_m_ee = 0;
					dt_int32 v_c = 1;
					dt_int32 izl = 0;
					for(auto iz = 0; iz < v.size(); iz++)
					{
						auto v_v = v[iz];

						if (v_v<v_lim[izl])
						{
							fcn_kh_sum(v_m, v_v, v_m_ee);
							v_c++;
						}
						else
						{
							v_plane.push_back(v_m/v_c);
							v_m = v_v;
							v_m_ee = 0;
							v_c = 1;
							izl++;
						}
					} 

					v_plane.push_back(v_m/v_c);
					v_plane.shrink_to_fit();

					return v_plane;
				}

				// calculate planes
				TVctr operator()(T v_min, T v_max, T dv, eMatch_Border mb=emb_minmax)
				{
					const T v_eps = 1e-4;

					TVctr v_plane;

					if (fabs(v_max-v_min)<v_eps)
					{
						v_plane.resize(1);
						v_plane[0] = 0.5*(v_min+v_max);
						return v_plane;
					}

					if (v_max<v_min)
					{
						return v_plane;
					}

					auto quot = [v_eps](const T& a, const T& b)->dt_int32
					{
						return static_cast<dt_int32>(::floor(a/b+v_eps));
					};

					T s_v = v_max-v_min;
					const dt_int32 nv = max(1, quot(s_v, dv))+1;

					switch (mb)
					{
						case emb_min:
						{
							v_plane.resize(nv);
							for(auto iv=0; iv<nv; iv++)
							{
								v_plane[iv] = v_min + iv*dv;
							}
						}
						break;
						case emb_max:
						{
							v_plane.resize(nv);
							for(auto iv=0; iv<nv; iv++)
							{
								v_plane[nv-1-iv] = v_max - iv*dv;
							}
						}
						break;
						case emb_minmax:
						{
							const auto dv_b = dv + 0.5*(s_v-(nv-1)*dv);

							v_plane.resize(nv);
							v_plane[0] = v_min;
							for(auto iv=1; iv<nv; iv++)
							{
								const auto dv_t = ((iv==1)||(iv==nv-1))?dv_b:dv;
								v_plane[iv] = v_plane[iv-1] + dv_t;
							}
						}
						break;
					}
				

					return v_plane;
				}

			private:
				// calculate corrected histogram
				TVctr_I fcn_hist(TVctr& v, dt_float64 dv, dt_float64 v_min, dt_float64 v_max)
				{
					const auto v_l = ::fmax(v_max-v_min, dv);
					const dt_int32 n_bins = static_cast<dt_int32>(::ceil(v_l/dv));

					TVctr_I v_hist(n_bins, 0);
					for(auto iv = 0; iv< v.size(); iv++)
					{
						 auto v_id = dt_float64(v[iv]);
						 auto ih = static_cast<dt_int32>(::floor((v_id-v_min)/dv));
						 auto v_imin = v_min + (ih-1)*dv;
						 auto v_imax = v_imin + dv;

						 if (v_id<v_imin)
						 {
							 for(auto ik = ih; ik >= 0; ik--)
							 {
								 v_imin = v_min + (ik-1)*dv;
								 v_imax = v_imin + dv;
								 if ((v_imin<=v_id) && (v_id<v_imax))
								 {
									ih = ik-1;
									break;
								 }
							 }
							}
						 else if (v_id>v_imax)
						 {
							 for(auto ik = ih; ik < n_bins; ik++)
							 {
								 v_imin = v_min + ik*dv;
								 v_imax = v_imin + dv;
								 if ((v_imin<=v_id) && (v_id<v_imax))
								 {
									ih = ik;
									break;
								 }
							 }
						 }
						 ih = max(0, min(n_bins-1, ih));
						 v_hist[ih]++;
					}

					while (v_hist.back()==0)
					{
						v_hist.pop_back();
					}

					for(auto ih = 1; ih < v_hist.size()-1; ih++)
					{
						dt_bool bn = (ih<v_hist.size()-2)?(0<v_hist[ih+2]):false;
						bn = (0<v_hist[ih-1]) && ((0<v_hist[ih+1])||bn);
						if ((v_hist[ih]==0) && bn)
						{
							v_hist[ih] = 1;
						}
					}

					return v_hist;
				}

				dt_float64 dv;
		};

		/*********************** rotation parameters *************************/
		template <class T>
		struct Rot_Par
		{
			T theta;		// angle
			R_3d<T> u0;		// unitary vector			
			eRot_Point_Typ center_type;		// 1: geometric center, 2: User define		
			R_3d<T> center_p;		// rotation point

			Rot_Par(): theta(0), u0(0, 0, 1), 
			center_type(erpt_Geometric_Center), center_p(1, 0, 0) {}

			void validate_parameter()
			{
				u0.normalize();
			}

			dt_bool is_geometric_center() const
			{
				return center_type == erpt_Geometric_Center;
			}

			dt_bool is_user_define() const
			{
				return center_type == erpt_user_def;
			}

			dt_bool is_rot_active() const
			{
				return fcn_is_nzero(theta);
			}
		};

		/******************* phonon model parameters *************************/
		struct Phonon_Par
		{
			ePhonon_Model model;		// 1: Still atom model, 2: Absorptive potential model, 3: Frozen phonon
			dt_bool coh_contrib;		// true, false
			dt_bool single_conf;		// single configuration: true, false			
			dt_int32 dist;		// 1: Gaussian (Phonon_Par distribution)
			dt_int32 seed;		// Random seed (frozen phonon)
			dt_int32 nconf;		// true: single phonon configuration, false: number of frozen phonon configurations
			dt_int32 iconf_0;		// initial configuration
			dt_bool dim_x;		// x - phonon dimension (true, false)
			dt_bool dim_y;		// y - phonon dimension (true, false)
			dt_bool dim_z;		// z - phonon dimension (true, false)

			Phonon_Par(): model(ePM_Still_Atom), coh_contrib(false), single_conf(false), dist(1), seed(300183), 
			nconf(1), iconf_0(1), dim_x(true), dim_y(true), dim_z(false) {}

			void set_dim(const dt_int32& Dim)
			{
				switch (Dim)
				{
					case 111:
					{
						dim_x = true;
						dim_y = true;
						dim_z = true;
					}
					break;
					case 110:
					{
						dim_x = true;
						dim_y = true;
						dim_z = false;
					}
					break;
					case 101:
					{
						dim_x = true;
						dim_y = false;
						dim_z = true;
					}
					break;
					case 11:
					{
						dim_x = false;
						dim_y = true;
						dim_z = true;
					}
					break;
					case 100:
					{
						dim_x = true;
						dim_y = false;
						dim_z = false;
					}
					break;
					case 10:
					{
						dim_x = false;
						dim_y = true;
						dim_z = false;
					}
					break;
					case 1:
					{
						dim_x = false;
						dim_y = false;
						dim_z = true;
					}
					break;
				}
			}

			void validate_parameter()
			{
				seed = max(1, seed);
				nconf = (!is_frozen_phonon())?1:max(1, nconf);
				iconf_0 = (!is_frozen_phonon())?1:(single_conf)?nconf:1;
			}

			dt_bool is_still_atom() const
			{
				return model == ePM_Still_Atom;
			}

			dt_bool is_absorptive_model() const
			{
				return model == ePM_Absorptive_Model;
			}

			dt_bool is_frozen_phonon() const
			{
				return model == ePM_Frozen_Phonon;
			}

			dt_bool is_frozen_phonon_float32_conf() const
			{
				return is_frozen_phonon() && single_conf;
			}

			dt_int32 number_conf()
			{
				return (nconf-iconf_0+1);
			}
		};

		/************************** stem fetector ****************************/
		inline
		dt_bool is_detector_circular(const eDetector_Typ &det_type)
		{
			return det_type == mt::edt_Circular;
		}

		inline
		dt_bool is_detector_radial(const eDetector_Typ &det_type)
		{
			return det_type == mt::edt_Radial;
		}

		inline
		dt_bool is_detector_matrix(const eDetector_Typ &det_type)
		{
			return det_type == mt::edt_Matrix;
		}

		template <class T, eDev Dev>
		struct Detector
		{
			using value_type = T;
			using size_type = dt_int32;

			static const eDev device = Dev;

			Detector(): type(mt::edt_Circular) {}

			size_type size() const
			{
				size_type size_out = 0;
				switch (type)
				{
					case mt::edt_Circular:
					{
						size_out = g_inner.size();
					}
					break;
					case mt::edt_Radial:
					{
						size_out = fx.size();
					}
						break;
					case mt::edt_Matrix:
					{
						size_out = fR.size();
					}
					break;
				}
				return size_out;
			}

			void clear()
			{
				g_inner.clear();
				g_outer.clear();
				fx.clear();
				fR.clear();
				fcn.clear();
				grid_1d.clear();
				grid_2d.clear();
			}

			void resize(const size_type& new_size)
			{
				switch (type)
				{
					case mt::edt_Circular:
					{
						g_inner.resize(new_size);
						g_outer.resize(new_size);
					}
					break;
					case mt::edt_Radial:
					{
						fx.resize(new_size);
						fcn.resize(new_size);
						grid_1d.resize(new_size);
					}
						break;
					case mt::edt_Matrix:
					{
						fR.resize(new_size);
						fcn.resize(new_size);
						grid_2d.resize(new_size);
					}
					break;
				}
			}

			template <class TDetector> 
			void assign(TDetector &detector)
			{
				type = detector.type;
				g_inner.assign(detector.g_inner.begin(), detector.g_inner.end());
				g_outer.assign(detector.g_outer.begin(), detector.g_outer.end());

				fx.resize(detector.fx.size());
				for(auto i = 0; i<detector.fx.size(); i++)
				{
					fx[i].assign(detector.fx[i].begin(), detector.fx[i].end());
					fcn[i] = detector.fcn[i];
					grid_1d[i] = detector.grid_1d[i];
				}

				fR.resize(detector.fR.size());
				for(auto i = 0; i<detector.fR.size(); i++)
				{
					fR[i].assign(detector.fR[i].begin(), detector.fR[i].end());
					fcn[i] = detector.fcn[i];
					grid_2d[i] = detector.grid_2d[i];
				}
			}

			template <class TDetector> 
			Detector<T, Dev>& operator=(TDetector &detector)
			{
				assign(detector);
				return *this;
			}

			dt_bool is_detector_circular() const
			{
				return mt::is_detector_circular(type);
			}

			dt_bool is_detector_radial() const
			{
				return mt::is_detector_radial(type);
			}

			dt_bool is_detector_matrix() const
			{
				return mt::is_detector_matrix(type);
			}

			eDetector_Typ type;		// mt::edt_Circular = 1, mt::edt_Radial = 2, mt::edt_Matrix = 3
			Vctr<T, edev_cpu> g_inner;		// Inner aperture Ang^-1
			Vctr<T, edev_cpu> g_outer;		// Outer aperture Ang^-1
			Vctr<Vctr<T, Dev>, edev_cpu> fx;		// radial sensitivity value
			Vctr<Vctr<T, Dev>, edev_cpu> fR;		// 2D sensitivity value
			std::vector<Grid_2d<T>> grid_1d;		// grid_1d
			std::vector<Grid_2d<T>> grid_2d;		// grid_2d
			std::vector<std::string> fcn;		// file names
		};

		/************************* stem intensity ****************************/
		template <class TVctr>
		struct Det_Int
		{
			using value_type = typename TVctr::value_type;
			using size_type = dt_int32;

			static const eDev device = edev_cpu;

			size_type size() const
			{
				return image.size();
			}

			Vctr<TVctr, edev_cpu> image;
		};

		/******************************** scan *******************************/
		template <class T>
		struct Scan
		{
			public:
				using value_type = T;
				using size_type = dt_int32;

				eScan_Typ type;		// 1: Line, 2: Area, 3: User_Define
				dt_bool pbc;		// periodic boundary conditions
				dt_int32 ns;		// number of sampling points
				dt_int32 nx;
				dt_int32 ny;
				R_2d<T> R_0;		// initial scanning position
				R_2d<T> R_e;		// final scanning position

				R_2d<T> dR;

				Vctr<R_2d<T>, edev_cpu> R;
				Vctr<T, edev_cpu> mR;

				size_type size() const
				{
					return R.size();
				}

				Scan(): type(eST_Line), pbc(false), ns(1), nx(0), ny(0), 
				dR(0, 0), R_0(0, 0), R_e(0, 0) {};

				template <class TScanning> 
				void assign(TScanning &scanning)
				{
					type = scanning.type;
					pbc = scanning.pbc;
					ns = scanning.ns;
					nx = scanning.nx;
					ny = scanning.ny;
					R_0 = scanning.R_0;
					R_e = scanning.R_e;
					dR = scanning.dR;

					R = scanning.R;
					mR = scanning.mR;
				}

				template <class TScanning> 
				Scan<T>& operator=(TScanning &scanning)
				{
					assign(scanning);
					return *this;
				}

				void set_default()
				{
					type = eST_Line;
					pbc = false;
					ns = 1;
					R_0 = T(0);
					R_e = T(0);
					dR = T(0);
					R.clear();
					mR.clear();
				}

				// dt_int32 size() const { return nx*ny; }

				T rx(const dt_int32& ix) const 
				{
					return (R_0.x + ix*dR.x);
				}

				T ry(const dt_int32& iy) const
				{ 
					return (R_0.y + iy*dR.y);
				}

				Vctr<T, edev_cpu> x()
				{
					Vctr<T, edev_cpu> x;
					x.reserve(R.size());
					for(auto ik = 0; ik<R.size(); ik++)
					{
						x.push_back(R[ik].x);
					}
					return x;
				}

				Vctr<T, edev_cpu> y()
				{
					Vctr<T, edev_cpu> y;
					y.reserve(R.size());
					for(auto ik = 0; ik<R.size(); ik++)
					{
						y.push_back(R[ik].y);
					}
					return y;
				}

				void set_grid()
				{
					if (!is_user_define() & (ns <= 0))
					{
						ns = nx = ny = 0;
						R.clear();
						mR.clear();

						return;
					}

					nx = ny = ns;
					if (is_line())
					{
						auto R_u = R_e-R_0;
						T ds = R_u.norm();
						T theta = atan2(R_u.y, R_u.x);
						T cos_theta = cos(theta);
						cos_theta = (fcn_is_zero(cos_theta))?0:cos_theta;
						T sin_theta = sin(theta);
						theta = (fcn_is_zero(theta))?0:theta;

						dR.x = ds*cos_theta/((pbc)?ns:(ns-1));
						dR.y = ds*sin_theta/((pbc)?ns:(ns-1));

						R.resize(ns);
						mR.resize(ns);

						for(auto ixy = 0; ixy < ns; ixy++)
						{
							R[ixy] = R_2d<T>(rx(ixy), ry(ixy));
							mR[ixy] = norm(R[ixy]-R_0);
						}
					}
					else if (is_area())
					{
						auto R_u = R_e-R_0;
						if (fabs(R_u.x)>fabs(R_u.y))
						{
							dR.x = R_u.x/((pbc)?ns:(ns-1));
							dR.y = std::copysign(dR.x, R_u.y);
							ny = dt_int32(::floor(R_u.y/dR.y+Epsilon<T>::rel+0.5));
							ny += (pbc)?0:1;
						}
						else
						{
							dR.y = R_u.y/((pbc)?ns:(ns-1));
							dR.x = std::copysign(dR.y, R_u.x);
							nx = dt_int32(::floor(R_u.x/dR.x+Epsilon<T>::rel+0.5));
							nx += (pbc)?0:1;
						}

						R.resize(size());
						mR.resize(size());

						for(auto ix = 0; ix<nx; ix++)
						{
							for(auto iy = 0; iy<ny; iy++)
							{
								const dt_int32 ixy = ix*ny+iy;
								R[ixy] = R_2d<T>(rx(ix), ry(iy));
								mR[ixy] = norm(R[ixy]-R_0);
							}
						}
					}
					else
					{
						nx = ns = R.size();
						ny = 1;
						dR = T(0);
					}

					R.shrink_to_fit();
					mR.shrink_to_fit();
				}

				dt_bool is_line() const
				{
					return type == eST_Line;
				}

				dt_bool is_area() const
				{
					return type == eST_Area;
				}

 				dt_bool is_user_define() const
				{
					return type == eST_user_def;
				}
			private:
		};

		/******************** radial schrodinger equation ********************/
		template <class T>
		class In_Rad_Schr
		{
		public:
			T E_0;		// Acceleration Voltage
			ePot_Parm_Typ pot_parm_typ;		// Parameterization type
			dt_int32 n;		// Principal quantum number
			dt_int32 nr;		// number of grid points
			dt_int32 natomsM;		// number of atoms
			T* atomsM;		// atoms
		};
	}

#endif