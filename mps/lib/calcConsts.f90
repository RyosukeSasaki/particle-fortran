subroutine calcConsts()
  !定数の計算
  use consts_variables
  implicit none

  Radius_forNumberDensity = 2.1*PARTICLE_DISTANCE
  Radius_forGradient = 2.1*PARTICLE_DISTANCE
  Radius_forLaplacian = 3.1*PARTICLE_DISTANCE
  collisionDistance = 0.5*PARTICLE_DISTANCE

  call calcNZeroLambda()

end

subroutine calcNZeroLambda()
  use consts_variables
  implicit none
  real*8 :: calcWeight
  real*8 :: xj, yj, xi = 0d0, yi = 0d0
  real*8 :: distance2, distance
  integer :: iX, iY

  N0_forNumberDensity = 0d0
  N0_forGradient = 0d0
  N0_forLaplacian = 0d0

  do iX = -4, 4
    do iY = -4, 4
      if ((iX == 0) .and. (iY == 0)) cycle
      xj = PARTICLE_DISTANCE*dble(iX)
      yj = PARTICLE_DISTANCE*dble(iY)
      distance2 = (xj - xi)**2 + (yj - yi)**2
      distance = sqrt(distance2)

      N0_forNumberDensity = N0_forNumberDensity + calcWeight(distance, Radius_forNumberDensity)
      N0_forGradient = N0_forGradient + calcWeight(distance, Radius_forGradient)
      N0_forLaplacian = N0_forLaplacian + calcWeight(distance, Radius_forLaplacian)

      Lambda = Lambda + distance2*calcWeight(distance, Radius_forLaplacian)
    enddo
  enddo
  Lambda = Lambda/N0_forLaplacian

end
