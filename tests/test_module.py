import pytest
from decimal import Decimal

from src.module import MathTools


class TestFibonacci:
    def test_fibonacci_zero(self) -> None:
        """Test fibonacci returns 0 for n=0"""
        assert MathTools.fibonacci(0) == 0, f'expected 0, got {MathTools.fibonacci(0)}'

    def test_fibonacci_one(self) -> None:
        """Test fibonacci returns 1 for n=1"""
        assert MathTools.fibonacci(1) == 1, f'expected 1, got {MathTools.fibonacci(1)}'

    def test_fibonacci_sequence(self) -> None:
        """Test fibonacci returns correct value at n=10"""
        assert MathTools.fibonacci(10) == 55, (
            f'expected 55, got {MathTools.fibonacci(10)}'
        )

    def test_fibonacci_large(self) -> None:
        """Test fibonacci returns correct value at n=20"""
        assert MathTools.fibonacci(20) == 6765, (
            f'expected 6765, got {MathTools.fibonacci(20)}'
        )

    def test_fibonacci_negative_raises(self) -> None:
        """Test fibonacci raises ValueError for negative n"""
        with pytest.raises(ValueError):
            MathTools.fibonacci(-1)


class TestPi:
    def test_pi_two_digits(self) -> None:
        """Test pi returns 3.14 for digits=2"""
        result = MathTools.pi(2)
        assert result == Decimal('3.14'), f'expected 3.14, got {result}'

    def test_pi_five_digits(self) -> None:
        """Test pi returns 3.14159 for digits=5"""
        result = MathTools.pi(5)
        assert result == Decimal('3.14159'), f'expected 3.14159, got {result}'

    def test_pi_returns_decimal(self) -> None:
        """Test pi returns a Decimal instance"""
        result = MathTools.pi(3)
        assert isinstance(result, Decimal), f'expected Decimal, got {type(result)}'

    def test_pi_zero_digits_raises(self) -> None:
        """Test pi raises ValueError for digits=0"""
        with pytest.raises(ValueError):
            MathTools.pi(0)

    def test_pi_negative_digits_raises(self) -> None:
        """Test pi raises ValueError for negative digits"""
        with pytest.raises(ValueError):
            MathTools.pi(-5)


class TestRemainder:
    def test_remainder_positive(self) -> None:
        """Test remainder returns correct value for positive numbers"""
        result = MathTools.remainder(10, 3)
        assert result == 1, f'expected 1, got {result}'

    def test_remainder_zero_dividend(self) -> None:
        """Test remainder returns 0 when dividend is 0"""
        result = MathTools.remainder(0, 5)
        assert result == 0, f'expected 0, got {result}'

    def test_remainder_negative_dividend(self) -> None:
        """Test remainder handles negative dividend"""
        result = MathTools.remainder(-7, 3)
        assert result == (-7 % 3), f'expected {-7 % 3}, got {result}'

    def test_remainder_divisor_larger_than_dividend(self) -> None:
        """Test remainder when divisor is larger than dividend"""
        result = MathTools.remainder(3, 10)
        assert result == 3, f'expected 3, got {result}'

    def test_remainder_zero_divisor_raises(self) -> None:
        """Test remainder raises ValueError when divisor is zero"""
        with pytest.raises(ValueError):
            MathTools.remainder(10, 0)
