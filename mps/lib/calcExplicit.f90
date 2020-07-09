!陽的計算関連ルーチン

subroutine calcGravity()
  !外力項(重力)の計算
  use define
  use consts_variables
  implicit none
  integer :: i, j

  Acc = 0d0
  !$omp parallel private(j)
  !$omp do
  do i = 1, NumberOfParticle
  if (ParticleType(i) == PARTICLE_FLUID) then
    do j = 1, numDimension
      Acc(i, j) = Gravity(j)
    enddo
  endif
  enddo
  !$omp end do
  !$omp end parallel

end

subroutine calcViscosity()
  !粘性項の計算
  use define
  use consts_variables
  implicit none
  real*8 :: ViscosityTerm(numDimension)
  real*8 :: distance, weight
  real*8 :: calcWeight, calcDistance
  real*8 :: m
  integer :: i, j, k

  m = 2d0*numDimension/(N0_forLaplacian*Lambda)*KINEMATIC_VISCOSITY

  !$omp parallel private(ViscosityTerm, distance, weight, j, k)
  !$omp do
  do i = 1, NumberOfParticle
  if (ParticleType(i) == PARTICLE_FLUID) then
    ViscosityTerm = 0d0
    do j = 1, NumberOfParticle
      if (i == j) cycle
      distance = calcDistance(i, j)
      if (distance < Radius_forLaplacian) then
        weight = calcWeight(distance, Radius_forLaplacian)
        do k = 1, numDimension
          ViscosityTerm(k) = ViscosityTerm(k) + (Vel(j, k) - Vel(i, k))*weight
        enddo
      endif
    enddo
    do k = 1, numDimension
      Acc(i, k) = Acc(i, k) + ViscosityTerm(k)*m
    enddo
  endif
  enddo
  !$omp end do
  !$omp end parallel

end

subroutine moveParticleExplicit()
  !陽解法による粒子の移動
  use consts_variables
  implicit none
  integer :: i, j

  !$omp parallel private(j)
  !$omp do
  do i = 1, NumberOfParticle
  do j = 1, numDimension
    Vel(i, j) = Vel(i, j) + Acc(i, j)*dt
    Pos(i, j) = Pos(i, j) + Vel(i, j)*dt
  enddo
  enddo
  !$omp end do
  !$omp end parallel
  Acc = 0d0

end

subroutine collision()
  use define
  use consts_variables
  implicit none
  real*8 :: e = IMPACT_PARAMETER
  real*8 :: distance
  real*8 :: calcDistance
  real*8 :: impulse
  real*8 :: VelocityAfterCollision(NumberOfParticle, numDimension)
  real*8 :: velocity_ix, velocity_iy
  real*8 :: xij, yij
  real*8 :: mi, mj
  integer :: i, j

  CollisionState = .false.
  VelocityAfterCollision = Vel
  do i = 1, NumberOfParticle
    if (ParticleType(i) .ne. PARTICLE_FLUID) cycle
    mi = FLUID_DENSITY
    velocity_ix = Vel(i, 1)
    velocity_iy = Vel(i, 2)
    do j = 1, NumberOfParticle
      if (ParticleType(j) == PARTICLE_DUMMY) cycle
      if (i == j) cycle
      xij = Pos(j, 1) - Pos(i, 1)
      yij = Pos(j, 2) - Pos(i, 2)
      distance = calcDistance(i, j)
      if (distance < collisionDistance) then
        impulse = (velocity_ix - Vel(j, 1))*(xij/distance) + &
                  (velocity_iy - Vel(j, 2))*(yij/distance)
        if (impulse > 0d0) then
          CollisionState(i) = .true.
          CollisionState(j) = .true.
          mj = FLUID_DENSITY
          impulse = impulse*((1d0 + e)*mi*mj)/(mi + mj)
          velocity_ix = velocity_ix - (impulse/mi)*(xij/distance)
          velocity_iy = velocity_iy - (impulse/mi)*(yij/distance)
        endif
      endif
    enddo
    VelocityAfterCollision(i, 1) = velocity_ix
    VelocityAfterCollision(i, 2) = velocity_iy
  enddo

  !$omp parallel
  !$omp do
  do i = 1, NumberOfParticle
    if (ParticleType(i) .ne. PARTICLE_FLUID) cycle
    Pos(i, 1) = Pos(i, 1) + (VelocityAfterCollision(i, 1) - Vel(i, 1))*dt
    Pos(i, 2) = Pos(i, 2) + (VelocityAfterCollision(i, 2) - Vel(i, 2))*dt
    Vel(i, 1) = VelocityAfterCollision(i, 1)
    Vel(i, 2) = VelocityAfterCollision(i, 2)
  enddo
  !$omp end do
  !$omp end parallel

end
