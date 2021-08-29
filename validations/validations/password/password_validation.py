from validations.password.capital_min_validation import CapitalMinimum
from validations.password.maxlength_validation import MaxLength
from validations.password.minlength_validation import MinLength
from validations.password.no_spaces_validation import NoSpaces
from validations.password.numbers_min_validation import NumbersMinimum
from validations.password.small_lettter_min_validation import SmallLetterMinimum
from validations.password.special_min_validation import SpecialCharacterMinimum


class PasswordValidation:
    def __init__(
            self,
            min={},
            max={},
            capital_minimum={},
            special_character_minimum={},
            no_spaces={},
            numbers_minimum={},
            small_letter_minimum={},
            *args,
            **kwargs
    ):
        self.min = min
        self.max = max
        self.capital_minimum = capital_minimum
        self.special_character_minimum = special_character_minimum
        self.no_spaces = no_spaces
        self.numbers_minimum = numbers_minimum
        self.small_letter_minimum = small_letter_minimum

    def is_valid(self, value):
        min = MinLength(**self.min)
        min_validate = min.is_valid(value)
        if min_validate is not None:
            return min_validate
        max = MaxLength(**self.max)
        max_validate = max.is_valid(value)
        if max_validate is not None:
            return max_validate
        capital = CapitalMinimum(**self.capital_minimum)
        capital_validate = capital.is_valid(value)
        if capital_validate is not None:
            return capital_validate
        spec = SpecialCharacterMinimum(**self.special_character_minimum)
        spec_validate = spec.is_valid(value)
        if spec_validate is not None:
            return spec_validate
        nospace = NoSpaces(**self.no_spaces)
        nospace_validate = nospace.is_valid(value)
        if nospace_validate is not None:
            return nospace_validate
        number = NumbersMinimum(**self.numbers_minimum)
        number_validate = number.is_valid(value)
        if number_validate is not None:
            return number_validate
        small_letter = SmallLetterMinimum(**self.small_letter_minimum)
        small_letter_validate = small_letter.is_valid(value)
        if small_letter_validate is not None:
            return small_letter_validate

        return None
