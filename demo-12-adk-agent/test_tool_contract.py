"""Local boundary checks; these tests do not invoke BigQuery or Gemini."""
def valid_match_id(match_id): return bool(match_id and 5 <= len(match_id) <= 64)
def bounded_limit(limit): return min(max(int(limit), 1), 20)
def test_contracts():
    assert valid_match_id('match-apac-final-04')
    assert not valid_match_id('') and not valid_match_id('abc')
    assert bounded_limit(3) == 3 and bounded_limit(10000) == 20 and bounded_limit(0) == 1
if __name__ == '__main__':
    test_contracts(); print('Tool contract checks passed.')
