subroutine InitParticle(MaxNumberOfParticle, NumberOfParticle, Pos, Vel, ParticleType, PARTICLE_DISTANCE)
  implicit none
  integer, intent(in) :: MaxNumberOfParticle
  integer, intent(out) :: NumberOfParticle
  real*8, intent(inout) :: Pos(MaxNumberOfParticle, 2)
  real*8, intent(inout) :: Vel(MaxNumberOfParticle, 2), ParticleType(MaxNumberOfParticle)
  real*8, intent(in) :: PARTICLE_DISTANCE
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
      x = PARTICLE_DISTANCE*iX
      y = PARTICLE_DISTANCE*iY
      flagOfParticleGenerarion = .false.

      !dummy particle
      if (((x > -4*PARTICLE_DISTANCE + EPS) .and. (x <= 1d0 + 4*PARTICLE_DISTANCE + EPS)) &
          .and. ((y > 0d0 - 4*PARTICLE_DISTANCE + EPS) .and. (y <= 0.6 + EPS))) then
        ParticleType(i) = 2
        flagOfParticleGenerarion = .true.
      endif

      !wall particle
      if (((x > -2*PARTICLE_DISTANCE + EPS) .and. (x <= 1d0 + 2*PARTICLE_DISTANCE + EPS)) &
          .and. ((y > 0d0 - 2*PARTICLE_DISTANCE + EPS) .and. (y <= 0.6 + EPS))) then
        ParticleType(i) = 1
        flagOfParticleGenerarion = .true.
      endif

      !wall particle
      if (((x > -4*PARTICLE_DISTANCE + EPS) .and. (x <= 1d0 + 4*PARTICLE_DISTANCE + EPS)) &
          .and. ((y > 0.6 - 2*PARTICLE_DISTANCE + EPS) .and. (y <= 0.6 + EPS))) then
        ParticleType(i) = 1
        flagOfParticleGenerarion = .true.
      endif

      !empty region
      if (((x > 0d0 + EPS) .and. (x <= 1d0 + EPS)) .and. (y > 0d0 + EPS)) then
        flagOfParticleGenerarion = .false.
      endif

      !fluid particle
      if (((x > 0d0 + EPS) .and. (x <= 0.25 + EPS)) .and. ((y > 0d0 + EPS) .and. (y <= 0.5 + EPS))) then
        ParticleType(i) = 0
        flagOfParticleGenerarion = .true.
      endif

      !generate position and velocity
      if (flagOfParticleGenerarion .eqv. .true.) then
        Pos(i, 1) = x; Pos(i, 2) = y
        Vel(i, 1) = 0d0; Vel(i, 2) = 0d0
        i = i + 1
      endif

    enddo
  enddo

  NumberOfParticle = i - 1
  return

end
