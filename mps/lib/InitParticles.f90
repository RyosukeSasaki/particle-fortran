subroutine InitParticles()
  !粒子の初期値設定
  use define
  use consts_variables
  implicit none
  real*8 :: x, y
  real*8 :: EPS
  integer :: iX, iY
  integer :: nX, nY
  integer :: i = 0
  logical :: flagOfParticleGenerarion
  logical :: shift = .false.

  EPS = PARTICLE_DISTANCE*0.01
  nX = int(sizeX/PARTICLE_DISTANCE) + 7
  nY = int(sizeY/PARTICLE_DISTANCE) + 7
  do iX = -6, nX
    do iY = -6, nY
      x = PARTICLE_DISTANCE*dble(iX)
      if (shift .eqv. .true.) then
        y = PARTICLE_DISTANCE*dble(iY)
      else
        y = PARTICLE_DISTANCE*(dble(iY)+0.5)
      endif
      flagOfParticleGenerarion = .false.

      !dummy particle
      if (((x > -6*PARTICLE_DISTANCE + EPS) .and. (x <= sizeX + 6*PARTICLE_DISTANCE + EPS)) &
          .and. ((y > 0d0 - 0*PARTICLE_DISTANCE + EPS) .and. (y <= sizeY + EPS))) then
        ParticleType(i) = PARTICLE_DUMMY
        flagOfParticleGenerarion = .true.
      endif

      !wall particle
      if (((x > -3*PARTICLE_DISTANCE + EPS) .and. (x <= sizeX + 3*PARTICLE_DISTANCE + EPS)) &
          .and. ((y > 0d0 - 0*PARTICLE_DISTANCE + EPS) .and. (y <= sizeY + EPS))) then
        ParticleType(i) = PARTICLE_WALL
        flagOfParticleGenerarion = .true.
      endif

      !wall particle
      if (((x > -6*PARTICLE_DISTANCE + EPS) .and. (x <= sizeX + 6*PARTICLE_DISTANCE + EPS)) &
          .and. ((y > 0 - 3*PARTICLE_DISTANCE + EPS) .and. (y <= 0 + EPS))) then
        ParticleType(i) = PARTICLE_WALL
        flagOfParticleGenerarion = .true.
      endif

      !empty region
      if (((x > 0d0 + EPS) .and. (x <= sizeX + EPS)) .and. (y > -20d0 + EPS)) then
        flagOfParticleGenerarion = .false.
      endif

      !generate position and velocity
      if (flagOfParticleGenerarion .eqv. .true.) then
        Pos(i, 1) = x; Pos(i, 2) = y
        i = i + 1
      endif
      
    enddo
    if (shift .eqv. .true.) then
      shift = .false.
    else
      shift = .true.
    endif
  enddo

  NumberOfFluid = 0
  do iX = -6, nX
    do iY = -6, nY
      x = PARTICLE_DISTANCE*dble(iX)
      y = PARTICLE_DISTANCE*dble(iY)
      flagOfParticleGenerarion = .false.

      !fluid particle
      if (((x > 0d0 + EPS) .and. (x <= WsizeX + EPS)) .and. ((y > 0d0 + EPS) .and. (y <= WsizeY + EPS))) then
        ParticleType(i) = PARTICLE_FLUID
        flagOfParticleGenerarion = .true.
        NumberOfFluid = NumberOfFluid + 1
      endif

      !generate position and velocity
      if (flagOfParticleGenerarion .eqv. .true.) then
        Pos(i, 1) = x; Pos(i, 2) = y
        i = i + 1
      endif

    enddo
  enddo

  NumberOfParticle = i
  !allocate memory for particle quantities
  allocate (Vel(NumberOfParticle, numDimension))
  allocate (Acc(NumberOfParticle, numDimension))
  allocate (NumberDensity(NumberOfParticle))
  allocate (BoundaryCondition(NumberOfParticle))
  allocate (SourceTerm(NumberOfParticle))
  allocate (CoefficientMatrix(NumberOfParticle, NumberOfParticle))
  allocate (Pressure(NumberOfParticle))
  allocate (MinPressure(NumberOfParticle))
  allocate (CollisionState(NumberOfParticle))
  allocate (detachState(NumberOfParticle))
  detachState = .false.
  Vel = 0d0
  Acc = 0d0
  Pressure = 0d0
  MassOfParticle = FLUID_DENSITY*WsizeX*WsizeY*WsizeZ/NumberOfFluid

  return

end
