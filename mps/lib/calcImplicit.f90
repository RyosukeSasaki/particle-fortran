subroutine calcNumberDensity()
  !粒子数密度の計算
  use define
  use consts_variables
  implicit none
  real*8 :: distance, weight
  real*8 :: calcDistance, calcWeight
  integer :: i, j

  NumberDensity = 0d0
  do i = 1, NumberOfParticle
    if (ParticleType(i) == PARTICLE_DUMMY) cycle
    do j = 1, NumberOfParticle
      if (ParticleType(j) == PARTICLE_DUMMY) cycle
      if (i == j) cycle
      distance = calcDistance(i, j)
      weight = calcWeight(distance, Radius_forNumberDensity)
      NumberDensity(i) = NumberDensity(i) + weight
    enddo
  enddo

end

subroutine setBoundaryCondition()
  !境界条件の設定
  use define
  use consts_variables
  implicit none
  integer :: i

  !$omp parallel
  !$omp do
  do i = 1, NumberOfParticle
  if (ParticleType(i) == PARTICLE_DUMMY) then
    BoundaryCondition(i) = BOUNDARY_DUMMY
  elseif (NumberDensity(i) < THRESHOLD_RATIO_BETA*N0_forNumberDensity) then
    BoundaryCondition(i) = BOUNDARY_SURFACE
  else
    BoundaryCondition(i) = BOUNDARY_INNER
  endif
  enddo
  !$omp end do
  !$omp end parallel

end

subroutine setSourceTerm()
  !ポアソン方程式右辺の設定
  use define
  use consts_variables
  implicit none
  integer :: i

  SourceTerm = 0d0
  !$omp parallel
  !$omp do
  do i = 1, NumberOfParticle
    if (ParticleType(i) == PARTICLE_DUMMY) cycle
    if (BoundaryCondition(i) == BOUNDARY_INNER) then
      SourceTerm(i) = RELAXATION_COEF_FOR_PRESSURE*(1d0/dt**2)* &
                      (NumberDensity(i) - N0_forNumberDensity)/N0_forNumberDensity
    elseif (BoundaryCondition(i) == BOUNDARY_SURFACE) then
      SourceTerm(i) = 0d0
    endif
  enddo
  !$omp end do
  !$omp end parallel

end

subroutine setMatrix()
  !係数行列の設定
  use define
  use consts_variables
  implicit none
  real*8 :: distance
  real*8 :: calcDistance, calcWeight
  real*8 :: coefIJ, a
  integer :: i, j

  CoefficientMatrix = 0d0
  a = 2d0*numDimension/(N0_forLaplacian*Lambda)
  do i = 1, NumberOfParticle
    if (BoundaryCondition(i) .ne. BOUNDARY_INNER) cycle
    do j = 1, NumberOfParticle
      if (BoundaryCondition(j) == BOUNDARY_DUMMY) cycle
      if (i == j) cycle
      distance = calcDistance(i, j)
      if (distance >= Radius_forLaplacian) cycle
      coefIJ = a*calcWeight(distance, Radius_forLaplacian)/FLUID_DENSITY
      CoefficientMatrix(i, j) = -1d0*coefIJ
      CoefficientMatrix(i, i) = CoefficientMatrix(i, i) + coefIJ
    enddo
    CoefficientMatrix(i, i) = CoefficientMatrix(i, i) + COMPRESSIBILITY/(dt**2)
  enddo

end

subroutine GaussEliminateMethod()
  use define
  use consts_variables
  implicit none
  real*8 :: Terms, c
  integer :: i, j, k

  Pressure = 0d0
  do i = 1, NumberOfParticle - 1
    if (BoundaryCondition(i) .ne. BOUNDARY_INNER) cycle
    do j = i + 1, NumberOfParticle
      if (BoundaryCondition(j) == BOUNDARY_DUMMY) cycle
      c = CoefficientMatrix(j, i)/CoefficientMatrix(i, i)
      do k = i + 1, NumberOfParticle
        CoefficientMatrix(j, k) = CoefficientMatrix(j, k) - c*CoefficientMatrix(i, k)
      enddo
      SourceTerm(j) = SourceTerm(j) - c*SourceTerm(i)
    enddo
  enddo

  i = NumberOfParticle
  do
    i = i - 1
    if (i == 0) exit
    if (BoundaryCondition(i) .ne. BOUNDARY_INNER) cycle
    Terms = 0d0
    !$omp parallel
    !$omp do reduction(+:Terms)
    do j = i + 1, NumberOfParticle
      Terms = Terms + CoefficientMatrix(i, j)*Pressure(j)
    enddo
    !$omp end do
    !$omp end parallel
    Pressure(i) = (SourceTerm(i) - Terms)/CoefficientMatrix(i, i)
  enddo

end

subroutine GaussSeidelMethod()
  !Gauss-Seidel法によるポアソン方程式の計算
  use consts_variables
  implicit none
  real*8, parameter :: eps = 5
  integer :: i, j, iter
  real*8 :: x, bnorm, val

  bnorm = 0d0
  !$omp parallel
  !$omp do reduction(+:bnorm)
  do i = 1, NumberOfParticle
    bnorm = bnorm + SourceTerm(i)**2
  enddo
  !$omp end do
  !$omp end parallel
  bnorm = sqrt(bnorm)

  Pressure = 0d0
  do iter = 1, NumberOfParticle*10
  do i = 1, NumberOfParticle
    x = SourceTerm(i)
    !$omp parallel
    !$omp do reduction(-:x)
    do j = 1, NumberOfParticle
      if (i == j) cycle
      x = x - CoefficientMatrix(i, j)*Pressure(i)
    enddo
    !$omp end do
    !$omp end parallel
    val = val + x**2
    Pressure(i) = x/CoefficientMatrix(i, i)
  enddo
  val = sqrt(val)/bnorm
  if (val < eps) exit
  enddo
end

subroutine removeNegativePressure()
  !負圧の除去
  !粒子枢密を用いて計算しているため,境界付近で負圧が発生する
  use consts_variables
  implicit none
  integer ::i

  do i = 1, NumberOfParticle
    Pressure(i) = Max(Pressure(i), 0d0)
  enddo

end

subroutine setMinPressure()
  use define
  use consts_variables
  implicit none
  real*8 :: distance
  real*8 :: calcDistance
  integer :: i, j

  do i = 1, NumberOfParticle
    if (ParticleType(i) == PARTICLE_DUMMY) cycle
    MinPressure(i) = Pressure(i)
    do j = 1, NumberOfParticle
      if (ParticleType(j) == PARTICLE_DUMMY) cycle
      if (i == j) cycle
      distance = calcDistance(i, j)
      if (distance >= Radius_forGradient) cycle
      if (MinPressure(i) > Pressure(j)) then
        MinPressure(i) = Pressure(j)
      endif
    enddo
  enddo

end

subroutine calcPressureGradient()
  !圧力勾配の計算
  use define
  use consts_variables
  implicit none
  real*8 :: weight, distance, distance2
  real*8 :: calcWeight
  real*8 :: pIJ
  real*8 :: deltaIJ(numDimension)
  real*8 :: gradient(numDimension)
  integer :: i, j, k

  !$omp parallel private(gradient, distance, distance2, weight, deltaIJ, pIJ, j, k)
  !$omp do
  do i = 1, NumberOfParticle
    if (ParticleType(i) .ne. PARTICLE_FLUID) cycle
    gradient = 0d0
    do j = 1, NumberOfParticle
      if (i == j) cycle
      if (ParticleType(j) == PARTICLE_DUMMY) cycle
      distance2 = 0d0
      do k = 1, numDimension
        deltaIJ(k) = Pos(j, k) - Pos(i, k)
        distance2 = distance2 + deltaIJ(k)**2
      enddo
      distance = sqrt(distance2)
      if (distance < Radius_forGradient) then
        weight = calcWeight(distance, Radius_forGradient)
        pIJ = (Pressure(j) - MinPressure(i))/distance2
        do k = 1, numDimension
          gradient(k) = gradient(k) + deltaIJ(k)*pIJ*weight
        enddo
      endif
    enddo
    do k = 1, numDimension
      gradient(k) = gradient(k)*numDimension/N0_forGradient
      Acc(i, k) = -1d0*gradient(k)/FLUID_DENSITY
    enddo
  enddo
  !$omp end do
  !$omp end parallel

end

subroutine moveParticleImplicit()
  !陰解法による粒子の移動
  use consts_variables
  implicit none
  integer :: i, j

  !$omp parallel private(j)
  !$omp do
  do i = 1, NumberOfParticle
  do j = 1, numDimension
    Vel(i, j) = Vel(i, j) + Acc(i, j)*dt
    Pos(i, j) = Pos(i, j) + Acc(i, j)*dt**2
  enddo
  enddo
  !$omp end do
  !$omp end parallel
  Acc = 0d0

end
