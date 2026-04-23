from decimal import Decimal, getcontext


class MathTools:
    """A collection of mathematical computation utilities.

    Provides methods for computing Fibonacci numbers, Pi to a given
    number of decimal places, and the remainder of division.
    """

    @staticmethod
    def fibonacci(n: int) -> int:
        """Return the n-th Fibonacci number (0-indexed).

        Args:
            n: Non-negative index in the Fibonacci sequence.

        Returns:
            The n-th Fibonacci number.

        Raises:
            ValueError: If n is negative.
        """
        if n < 0:
            raise ValueError(f'n must be non-negative, got {n}')
        a, b = 0, 1
        for _ in range(n):
            a, b = b, a + b
        return a

    @staticmethod
    def pi(digits: int) -> Decimal:
        """Compute Pi to the given number of decimal places.

        Uses the Chudnovsky algorithm via the `decimal` module.

        Args:
            digits: Number of decimal places to compute.

        Returns:
            Pi as a Decimal rounded to the requested decimal places.

        Raises:
            ValueError: If digits is not positive.
        """
        if digits <= 0:
            raise ValueError(f'digits must be positive, got {digits}')
        getcontext().prec = digits + 10

        # Chudnovsky: pi = sqrt(640320^3) / (12 * S)
        # S = sum_k (-1)^k * M_k * (13591409 + 545140134*k) / 640320^(3k)
        # term tracks M_k * (-1)^k / 640320^(3k), starting at k=0 with term=1.
        c = Decimal(640320)
        series_sum = Decimal(0)
        term = Decimal(1)

        for k in range(digits + 10):
            series_sum += term * (13591409 + 545140134 * k)
            numer = -(6 * k + 1) * (6 * k + 2) * (6 * k + 3)
            numer *= (6 * k + 4) * (6 * k + 5) * (6 * k + 6)
            denom = (3 * k + 1) * (3 * k + 2) * (3 * k + 3)
            denom *= (k + 1) ** 3 * 640320**3
            term *= Decimal(numer) / Decimal(denom)
            if abs(term) < Decimal(10) ** -(digits + 5):
                break

        pi_value = (c**3).sqrt() / (12 * series_sum)
        return pi_value.quantize(Decimal(10) ** -digits)

    @staticmethod
    def remainder(dividend: int, divisor: int) -> int:
        """Return the remainder of dividing dividend by divisor.

        Args:
            dividend: The number to divide.
            divisor: The number to divide by.

        Returns:
            The remainder of the division.

        Raises:
            ValueError: If divisor is zero.
        """
        if divisor == 0:
            raise ValueError('divisor must not be zero')
        return dividend % divisor
