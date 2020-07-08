program main
  use consts_variables
  implicit none
  integer :: i, j, k
  character :: filename*128
  call omp_set_num_threads(8)

  call InitParticles()
  call calcConsts()
  do i = 1, 200
  do j = 1, 10
  call calcGravity()
  call calcViscosity()
  call moveParticleExplicit()
  call collision()
  call calcNumberDensity()
  call setBoundaryCondition()
  call setSourceTerm()
  call setMatrix()
  call GaussEliminateMethod()
  call removeNegativePressure()
  call setMinPressure()
  call calcPressureGradient()
  call moveParticleImplicit()
  enddo
  write (*, *) "Timestep: ", i*10
  write (filename, '("data/data", i4.4, ".dat")') i
  open (11, file=filename, status='replace')
  do k = 1, NumberOfParticle
  write (11, *) Pos(k, 1), Pos(k, 2), ParticleType(k)
  enddo
  close (11)
  enddo

  end
