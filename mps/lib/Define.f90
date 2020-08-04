module define
  implicit none
  integer, parameter :: PARTICLE_DUMMY = -1, PARTICLE_WALL = 1, PARTICLE_FLUID = 0
  integer, parameter :: BOUNDARY_DUMMY = -1, BOUNDARY_INNER = 0
  integer, parameter :: BOUNDARY_SURFACE_LOW = 1, BOUNDARY_SURFACE_HIGH = 2

end
