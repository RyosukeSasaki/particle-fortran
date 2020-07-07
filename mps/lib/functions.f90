real*8 function calcWeight(distance, radius)
  implicit none
  real*8, intent(in) :: distance, radius
  real*8 :: w

  if (distance >= radius) then
    w = 0
  else
    w = radius/distance - 1d0
  endif
  calcWeight = w
  return

end function

real*8 function calcDistance(i, j)
  use consts_variables
  implicit none
  real*8 :: distance2
  integer :: i, j, k

  distance2 = 0d0
  do k = 1, numDimension
    distance2 = distance2 + (Pos(j, k) - Pos(i, k))**2
  enddo
  calcDistance = sqrt(distance2)
  return

end function
