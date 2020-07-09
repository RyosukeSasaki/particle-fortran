program main
  use consts_variables
  implicit none
  integer, parameter :: interval = 1
  integer :: i, j, k
  character :: filename*128
  call omp_set_num_threads(8)

  dt = 0.001
  call InitParticles()
  call calcConsts()
  do i = 1, 2000
  do j = 1, interval
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
  write (*, *) "Timestep: ", i*interval
  write (filename, '("data/data", i4.4, ".dat")') i
  open (11, file=filename, status='replace')
  do k = 1, NumberOfParticle
    write (11, '(f6.3,X)', advance='no') Pos(k, 1)
    write (11, '(f6.3,X)', advance='no') Pos(k, 2)
    write (11, '(I2,X)', advance='no') ParticleType(k)
    write (11, '(f15.5,X)', advance='no') Pressure(k)
    if (CollisionState(k) .eqv. .true.) then
      write (11, '(I2)', advance='no') 1
    else
      write (11, '(I2)', advance='no') 0
    endif
    write (11, *)
  enddo
  close (11)
  enddo

end
