program main
  use consts_variables
  implicit none
  integer, parameter :: interval = 10
  integer :: i, j
  character :: filename*128
  character :: command*128
  call omp_set_num_threads(8)

  command = 'mkdir -p ' // dir // '; rm ' // dir // '/data*'
  call system(command) 

  filename = dir // "/thrust.dat"

  open (19, file=filename, status='replace')
  write (*, *) "write data to ", dir, "/. Pressure is ", WaterPressure

  call InitParticles()
  call calcConsts()
  call writeInit()
  call output(0)
  do i = 0, 240-1
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
    call output(i*interval+j)
  enddo
  write (*, *) "Timestep: ", (i+1)*interval
  enddo

  write (19, *) "#deltaV: ", deltaV
  close (19)

end

subroutine output(i)
  use consts_variables
  implicit none
  integer :: i, k
  character :: filename*128

  write (filename, '("/data", i4.4, ".dat")') i
  filename = dir // filename
  open (11, file=filename, status='new')
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
    write (11, *)
  enddo
  close (11)

end

subroutine writeInit()
  use consts_variables
  implicit none
  character :: filename*128

  filename = dir // "/init.txt"
  open (18, file=filename, status='replace')
  write (18, *) "dt: ", dt
  write (18, *) "Particle radius: ", PARTICLE_DISTANCE
  write (18, *) "Fluid density: ", FLUID_DENSITY
  write (18, *) "Water Size: ", WsizeX, " * ", WsizeY, " * ", WsizeZ
  write (18, *) "Pressure: ", WaterPressure
  write (18, *) "Number of Paricle: ", NumberOfParticle
  write (18, *) "Number of Fluid: ", NumberOfFluid
  write (18, *) "Mass of Fluid Paricle: ", MassOfParticle
  close (18)

end

subroutine detach(i)
  use consts_variables
  use define
  implicit none
  integer :: i,j
  real*8 :: VelocitySum
  logical :: n0

  n0 = .true.
  VelocitySum = 0d0
  do j = 1, NumberOfParticle
    if (ParticleType(j) .ne. PARTICLE_FLUID) cycle
    if (Pos(j, 2) < -0.01d0) then
      if (detachState(j) .eqv. .false.) then
        VelocitySum = VelocitySum - Vel(j, 2)
        detachState(j) = .true.
        n0 = .false.
      endif
    endif
  enddo
  deltaV = deltaV + VelocitySum*MassOfParticle
  if (n0 .eqv. .false.) then
    write (19, '(f6.4,X)', advance='no') i*dt
    write (19, '(f15.10,X)', advance='no') VelocitySum*MassOfParticle
    write (19, *)
  endif

end
