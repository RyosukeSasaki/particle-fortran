program main
  use consts_variables
  implicit none
  integer, parameter :: interval = 10
  integer :: i, j
  !call omp_set_num_threads(8)

  dt = 0.001
  call InitParticles()
  call calcConsts()
  call output(0)
  do i = 1, 400
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
  call output(i)
  enddo

end

subroutine output(i)
  use consts_variables
  implicit none
  integer :: i, k
  character :: filename*128

  write (filename, '("data2/data", i4.4, ".dat")') i
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

end
