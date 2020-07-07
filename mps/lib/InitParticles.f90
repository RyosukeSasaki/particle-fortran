subroutine InitParticles()
  !粒子の初期値設定
  use define
  use consts_variables
  implicit none
  real*8 :: x, y
  real*8 :: EPS
  integer :: iX, iY
  integer :: nX, nY
  integer :: i = 1
  logical :: flagOfParticleGenerarion

  EPS = PARTICLE_DISTANCE*0.01
  nX = int(1.0/PARTICLE_DISTANCE) + 5
  nY = int(0.6/PARTICLE_DISTANCE) + 5
  do iX = -4, nX
    do iY = -4, nY
      x = PARTICLE_DISTANCE*dble(iX)
      y = PARTICLE_DISTANCE*dble(iY)
      flagOfParticleGenerarion = .false.

      !dummy particle
      if (((x > -4*PARTICLE_DISTANCE + EPS) .and. (x <= 1d0 + 4*PARTICLE_DISTANCE + EPS)) &
          .and. ((y > 0d0 - 4*PARTICLE_DISTANCE + EPS) .and. (y <= 0.6 + EPS))) then
        ParticleType(i) = PARTICLE_DUMMY
        flagOfParticleGenerarion = .true.
      endif

      !wall particle
      if (((x > -2*PARTICLE_DISTANCE + EPS) .and. (x <= 1d0 + 2*PARTICLE_DISTANCE + EPS)) &
          .and. ((y > 0d0 - 2*PARTICLE_DISTANCE + EPS) .and. (y <= 0.6 + EPS))) then
        ParticleType(i) = PARTICLE_WALL
        flagOfParticleGenerarion = .true.
      endif

      !wall particle
      if (((x > -4*PARTICLE_DISTANCE + EPS) .and. (x <= 1d0 + 4*PARTICLE_DISTANCE + EPS)) &
          .and. ((y > 0.6 - 2*PARTICLE_DISTANCE + EPS) .and. (y <= 0.6 + EPS))) then
        ParticleType(i) = PARTICLE_WALL
        flagOfParticleGenerarion = .true.
      endif

      !empty region
      if (((x > 0d0 + EPS) .and. (x <= 1d0 + EPS)) .and. (y > 0d0 + EPS)) then
        flagOfParticleGenerarion = .false.
      endif

      !fluid particle
      if (((x > 0d0 + EPS) .and. (x <= 0.25 + EPS)) .and. ((y > 0d0 + EPS) .and. (y <= 0.5 + EPS))) then
        ParticleType(i) = PARTICLE_FLUID
        flagOfParticleGenerarion = .true.
      endif

      !generate position and velocity
      if (flagOfParticleGenerarion .eqv. .true.) then
        Pos(i, 1) = x; Pos(i, 2) = y
        i = i + 1
      endif

    enddo
  enddo

  NumberOfParticle = i - 1
  !allocate memory for particle quantities
  allocate (Vel(NumberOfParticle, numDimension))
  allocate (Acc(NumberOfParticle, numDimension))
  allocate (NumberDensity(NumberOfParticle))
  allocate (BoundaryCondition(NumberOfParticle))
  allocate (SourceTerm(NumberOfParticle))
  allocate (CoefficientMatrix(NumberOfParticle, NumberOfParticle))
  allocate (Pressure(NumberOfParticle))
  allocate (MinPressure(NumberOfParticle))
  Vel = 0d0
  Acc = 0d0
  Pressure = 0d0

  return

end
