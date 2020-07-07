program main
  use consts_variables
  implicit none
  integer :: i, j, k
  character :: filename*128

  call InitParticles()
  do i = 1, 1000
    do j = 1, 10
      call calcConsts()
      call calcGravity()
      call calcViscosity()
      call moveParticleExplicit()
      call calcNumberDensity()
      call setBoundaryCondition()
      call setSourceTerm()
      call setMatrix()
      call GaussEliminateMethod()
      call removeNegativePressure()
      call calcPressureGradient()
      call moveParticleImplicit()
    enddo
    write (*, *) "Timestep: ", i*10
    write (filename, '("data/data", i3.3, ".dat")') i
    open (11, file=filename, status='replace')
    do k = 1, NumberOfParticle
      write (11, *) Pos(k, 1), Pos(k, 2), ParticleType(k)
    enddo
    close (11)
  enddo

end
