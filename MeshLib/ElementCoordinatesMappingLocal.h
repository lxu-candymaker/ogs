/**
 * \copyright
 * Copyright (c) 2012-2015, OpenGeoSys Community (http://www.opengeosys.org)
 *            Distributed under a Modified BSD License.
 *              See accompanying file LICENSE.txt or
 *              http://www.opengeosys.org/project/license
 */

#ifndef ELEMENTCOORDINATESMAPPINGLOCAL_H_
#define ELEMENTCOORDINATESMAPPINGLOCAL_H_

#include <vector>

#ifdef OGS_USE_EIGEN
#include <Eigen/Eigen>
#else
#include "MathLib/LinAlg/Dense/DenseMatrix.h"
#endif

#include "MathLib/Point3d.h"

#include "MeshLib/CoordinateSystem.h"

namespace MeshLib
{
    class Element;
}

namespace MeshLib
{
#ifdef OGS_USE_EIGEN
typedef Eigen::Matrix<double, 3u, 3u, Eigen::RowMajor> RotationMatrix;
#else
typedef MathLib::DenseMatrix<double> RotationMatrix;
#endif

/**
 * This class maps node coordinates on intrinsic coordinates of the given element.
 */
class ElementCoordinatesMappingLocal
{
public:
    /**
     * Constructor
     * \param e                     Mesh element whose node coordinates are mapped
     * \param global_coord_system   Global coordinate system
     */
    ElementCoordinatesMappingLocal(const Element &e, const CoordinateSystem &global_coord_system);

    /// Destructor
    virtual ~ElementCoordinatesMappingLocal();

    /// return the global coordinate system
    const CoordinateSystem getGlobalCoordinateSystem() const { return _coords; }

    /// return mapped coordinates of the node
    const MeshLib::Node* getMappedCoordinates(size_t node_id) const
    {
        return _vec_nodes[node_id];
    }

    /// return a rotation matrix converting to global coordinates
    const RotationMatrix& getRotationMatrixToGlobal() const {return _matR2global;}

private:
    /// rotate points to local coordinates
    void rotateToLocal(const RotationMatrix &matR2local, std::vector<MeshLib::Node*> &vec_pt) const;

    /// get a rotation matrix to the global coordinates
    /// it computes R in x=R*x' where x is original coordinates and x' is local coordinates
    void getRotationMatrixToGlobal(
            const Element &e, const CoordinateSystem &coordinate_system,
            const std::vector<MeshLib::Node*> &vec_pt, RotationMatrix &matR2original) const;

private:
    const CoordinateSystem _coords;
    std::vector<MeshLib::Node*> _vec_nodes;
    RotationMatrix _matR2global;
};

}

#endif // ELEMENTCOORDINATESMAPPINGLOCAL_H_
