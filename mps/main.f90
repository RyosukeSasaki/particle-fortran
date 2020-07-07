program main
  use consts_variables
  implicit none
  integer :: i, j

  call InitParticles()
  do j = 1, 1000
    call calcConsts()
    call calcGravity()
    call calcViscosity()
    call moveParticleExplicit()
    call calcNumberDensity()
    call setBoundaryCondition()
    call setSourceTerm()
    call setMatrix()
!    call GaussSeidelMethod()
    call GaussEliminateMethod()
    call removeNegativePressure()
    call calcPressureGradient()
    call moveParticleImplicit()
  enddo
  do i = 1, NumberOfParticle
    write (*, *) Pos(i, 1), Pos(i, 2), ParticleType(i)
  enddo

end
