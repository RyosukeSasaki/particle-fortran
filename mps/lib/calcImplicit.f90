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
  integer :: i, j, HIGHEST_INDEX
  real*8,parameter :: EPS = PARTICLE_DISTANCE * 0.01
  real*8 :: HIGHEST
  
  !$omp parallel
  !$omp do
  do i = 1, NumberOfParticle
    if (ParticleType(i) == PARTICLE_DUMMY) then
      BoundaryCondition(i) = BOUNDARY_DUMMY
    elseif (NumberDensity(i) < (THRESHOLD_RATIO_BETA*N0_forNumberDensity)) then
      BoundaryCondition(i) = BOUNDARY_SURFACE_LOW
    else
      BoundaryCondition(i) = BOUNDARY_INNER
    endif
  enddo
  !$omp end do
  !$omp end parallel
  i = 1
  do
    if (PARTICLE_DISTANCE*dble(i) >= (sizeX + 4*PARTICLE_DISTANCE + EPS)) exit
    HIGHEST = 0d0
    HIGHEST_INDEX = 0
    do j = 1, NumberOfParticle
      if (BoundaryCondition(j) .ne. BOUNDARY_SURFACE_LOW) cycle
      if ((Pos(j, 1) >  (PARTICLE_DISTANCE*(i-1) + EPS)) .and. (Pos(j, 1) <= (PARTICLE_DISTANCE*i + EPS))) then
        if (Pos(j, 2) > HIGHEST) then
          HIGHEST_INDEX = j
          HIGHEST = Pos(j, 2)
        endif
      endif 
    enddo
    BoundaryCondition(HIGHEST_INDEX) = BOUNDARY_SURFACE_HIGH
    !write(*,*) PARTICLE_DISTANCE*dble(i)
    i = i + 1
  enddo


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
    if (BoundaryCondition(i) == BOUNDARY_SURFACE_LOW) cycle
    if (BoundaryCondition(i) == BOUNDARY_SURFACE_HIGH) cycle
    if (BoundaryCondition(i) == BOUNDARY_INNER) then
      SourceTerm(i) = RELAXATION_COEF_FOR_PRESSURE*(1d0/dt**2)* &
                      (NumberDensity(i) - N0_forNumberDensity)/N0_forNumberDensity
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
      !$omp parallel
      !$omp do
      do k = i + 1, NumberOfParticle
        CoefficientMatrix(j, k) = CoefficientMatrix(j, k) - c*CoefficientMatrix(i, k)
      enddo
      !$omp end do
      !$omp end parallel
      SourceTerm(j) = SourceTerm(j) - c*SourceTerm(i)
    enddo
  enddo

  i = NumberOfParticle
  do
    i = i - 1
    if (i == 0) exit
    if (BoundaryCondition(i) == BOUNDARY_INNER) then
      Terms = 0d0
      do j = i + 1, NumberOfParticle
        Terms = Terms + CoefficientMatrix(i, j)*Pressure(j)
      enddo
      Pressure(i) = (SourceTerm(i) - Terms)/CoefficientMatrix(i, i)
    else if (BoundaryCondition(i) == BOUNDARY_SURFACE_HIGH) then
      Pressure(i) = WaterPressure
    endif
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

  !$omp parallel
  !$omp do
  do i = 1, NumberOfParticle
    if (Pressure(i) < 0d0) Pressure(i) = 0d0
    !if (Pressure(i) > 30000d0) Pressure(i) = 30000d0
  enddo
  !$omp end do
  !$omp end parallel

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
    !$omp parallel
    !$omp do
    do j = 1, NumberOfParticle
      if (ParticleType(j) == PARTICLE_DUMMY) cycle
      if (i == j) cycle
      distance = calcDistance(i, j)
      if (distance >= Radius_forGradient) cycle
      if (MinPressure(i) > Pressure(j)) then
        MinPressure(i) = Pressure(j)
      endif
    enddo
    !$omp end do
    !$omp end parallel
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
        pIJ = (Pressure(j) - Pressure(i))/distance2
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
