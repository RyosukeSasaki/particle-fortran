module consts_variables
  implicit none
  !initial value of particle distance
  real*8, parameter :: PARTICLE_DISTANCE = 0.025
  real*8, parameter :: FLUID_DENSITY = 1000
  real*8, parameter :: KINEMATIC_VISCOSITY = 1.0e-6
  !threshold of whether the particle is surface or inside
  real*8, parameter :: THRESHOLD_RATIO_BETA = 0.97
  !圧力計算の緩和係数
  real*8, parameter :: RELAXATION_COEF_FOR_PRESSURE = 0.2
  !圧縮率(Pa^(-1))
  real*8, parameter :: COMPRESSIBILITY = 0.45e-9
  real*8, parameter :: dt = 0.001
  integer, parameter :: MaxNumberOfParticle = 5000
  integer, parameter :: numDimension = 2

  real*8 :: Radius_forNumberDensity, Radius_forGradient, Radius_forLaplacian
  real*8 :: N0_forNumberDensity, N0_forGradient, N0_forLaplacian
  real*8 :: Lambda
  real*8 :: collisionDistance

  real*8 :: Pos(MaxNumberOfParticle, numDimension)
  real*8 :: Gravity(numDimension)
  ! 0:Fluid, 1:Wall, 2:Dummy
  real*8 :: ParticleType(MaxNumberOfParticle)
  data Gravity/0d0, -9.8/
  real*8, allocatable :: Vel(:, :)
  real*8, allocatable :: Acc(:, :)
  real*8, allocatable :: Pressure(:)
  real*8, allocatable :: MinPressure(:)
  real*8, allocatable :: NumberDensity(:)
  real*8, allocatable :: BoundaryCondition(:)
  real*8, allocatable :: SourceTerm(:)
  real*8, allocatable :: CoefficientMatrix(:, :)

  integer :: NumberOfParticle

end
