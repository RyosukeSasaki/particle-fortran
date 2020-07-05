program main
  implicit none
  integer, parameter :: MaxNumberOfParticle = 5000
  real*8, parameter :: PARTICLE_DISTANCE = 0.025
  integer :: NumberOfParticle
  real*8 :: Pos(MaxNumberOfParticle, 2)
  real*8 :: Vel(MaxNumberOfParticle, 2), ParticleType(MaxNumberOfParticle)
  integer :: i

  call InitParticle(MaxNumberOfParticle, NumberOfParticle, Pos, Vel, ParticleType, PARTICLE_DISTANCE)
  do i = 1, NumberOfParticle
    write (*, *) Pos(i, 1), Pos(i, 2), ParticleType(i)
  enddo

end
