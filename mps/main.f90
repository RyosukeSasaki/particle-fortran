program main
  use consts_variables
  implicit none
  integer, parameter :: interval = 1
  integer :: i, j
  !call omp_set_num_threads(8)

  dt = 0.0002d0

  open (19, file="data3/thrust.dat", status='replace')

  call InitParticles()
  call calcConsts()
  call output(0)
  do i = 1, 10
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
    call detach(i*interval+j)
  enddo
  write (*, *) "Timestep: ", i*interval
  call output(i)
  enddo

  close (19)

end

subroutine output(i)
  use consts_variables
  implicit none
  integer :: i, k
  character :: filename*128

  write (filename, '("data3/data", i4.4, ".dat")') i
  open (11, file=filename, status='replace')
  do k = 1, NumberOfParticle
    write (11, '(f6.3,X)', advance='no') Pos(k, 1)
    write (11, '(f6.3,X)', advance='no') Pos(k, 2)
    write (11, '(I2,X)', advance='no') ParticleType(k)
    write (11, '(f15.5,X)', advance='no') Pressure(k)
    if (CollisionState(k) .eqv. .true.) then
      write (11, '(I2,X)', advance='no') 1
    else
      write (11, '(I2,X)', advance='no') 0
    endif
    write (11, '(I2)', advance='no') BoundaryCondition(k)
    write (11, *)
  enddo
  close (11)

end

subroutine detach(i)
  use consts_variables
  implicit none
  integer :: i,j
  real*8 :: VelocitySum

  VelocitySum = 0d0
  do j = 1, NumberOfParticle
    if (Pos(j, 2) < -0.01d0) then
      if (detachState(j) .eqv. .false.) then
        VelocitySum = VelocitySum + Vel(j, 2)
        detachState(j) = .true.
      endif
    endif
  enddo
  write (19, '(f6.4,X)', advance='no') i*dt
  write (19, '(f15.10,X)', advance='no') VelocitySum*MassOfParticle
  write (19, *)

end