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
