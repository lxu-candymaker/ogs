INCLUDE(ExternalProject)

SET(OGS_VTK_VERSION 6.0.0)
SET(OGS_VTK_REQUIRED_LIBS
	vtkIOXML
)
IF(OGS_BUILD_GUI)
	SET(OGS_VTK_REQUIRED_LIBS ${OGS_VTK_REQUIRED_LIBS}
		vtkRenderingCore
		vtkGUISupportQt
		vtkInteractionWidgets
		vtkFiltersTexture
		vtkIONetCDF
		vtkIOLegacy
		vtkIOExport
	)
ENDIF()

IF(VTK_FOUND AND VTK_DIR MATCHES "${CMAKE_BINARY_DIR}/External/vtk/src/VTK-build")
	MESSAGE(STATUS "Using system vtk.")
	INCLUDE( ${VTK_USE_FILE} )
	RETURN()
ENDIF()

IF(NOT VTK_DIR)
	MESSAGE(STATUS "Using local vtk.")
	SET(VTK_DIR ${CMAKE_BINARY_DIR}/External/vtk/src/VTK-build CACHE PATH "" FORCE)
ENDIF()
FIND_PACKAGE(VTK ${OGS_VTK_VERSION} COMPONENTS ${OGS_VTK_REQUIRED_LIBS} )

IF(VTK_FOUND)
	INCLUDE( ${VTK_USE_FILE} )
ENDIF()

# Set archive sources
IF(WIN32)
	SET(VTK_ARCHIVE_MD5 34c47de28660b41c5f96cb3c7f420dd2)
	SET(VTK_URL "http://www.vtk.org/files/release/6.0/vtk-${OGS_VTK_VERSION}.zip")
ELSE()
	SET(VTK_ARCHIVE_MD5 72ede4812c90bdc55172702f0cad02bb)
	SET(VTK_URL "http://www.vtk.org/files/release/6.0/vtk-${OGS_VTK_VERSION}.tar.gz")
ENDIF()

IF(OGS_BUILD_GUI)
	SET(OGS_VTK_CMAKE_ARGS "-DVTK_Group_Qt:BOOL=ON")
ENDIF()

IF(WIN32)
	FOREACH(VTK_LIB ${OGS_VTK_REQUIRED_LIBS})
		IF(NOT DEFINED VTK_MAKE_COMMAND)
			SET(VTK_MAKE_COMMAND
				cmake --build . --config Release --target ${VTK_LIB} &&
				cmake --build . --config Debug --target ${VTK_LIB})
		ELSE()
			SET(VTK_MAKE_COMMAND
				${VTK_MAKE_COMMAND} &&
				cmake --build . --config Release --target ${VTK_LIB} &&
				cmake --build . --config Debug --target ${VTK_LIB})
		ENDIF()
	ENDFOREACH()
	# MESSAGE(STATUS ${VTK_MAKE_COMMAND})
	SET(VTK_PACTH_COMMAND "")
ELSE()
	IF($ENV{CI})
		SET(VTK_MAKE_COMMAND make ${OGS_VTK_REQUIRED_LIBS})
	ELSE()
		SET(VTK_MAKE_COMMAND make -j ${NUM_PROCESSORS} ${OGS_VTK_REQUIRED_LIBS})
	ENDIF()
	SET(VTK_PACTH_COMMAND patch -p1 -t -N < ${CMAKE_CURRENT_SOURCE_DIR}/scripts/cmake/ExternalProjectVtk-6.0.0.patch)
ENDIF()

ExternalProject_Add(VTK
	PREFIX ${CMAKE_BINARY_DIR}/External/vtk
	URL ${VTK_URL}
	URL_MD5 ${VTK_ARCHIVE_MD5}
	CMAKE_ARGS
		-DBUILD_SHARED_LIBS:BOOL=OFF
		-DBUILD_TESTING:BOOL=OFF
		-DCMAKE_BUILD_TYPE:STRING=Release
		${OGS_VTK_CMAKE_ARGS}
	PATCH_COMMAND ${VTK_PACTH_COMMAND}
	BUILD_COMMAND ${VTK_MAKE_COMMAND}
	INSTALL_COMMAND ""
)


IF(NOT ${VTK_FOUND})
	# Rerun cmake in initial build
	ADD_CUSTOM_TARGET(VtkRescan ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR} DEPENDS VTK)
ELSE()
	ADD_CUSTOM_TARGET(VtkRescan) # dummy target for caching
ENDIF()
