import localUnitTest from './LocalUnit.test';
import contractMapperTest from './ContractMapper.test';

export default function testsuite() {
  localUnitTest();
  contractMapperTest();
}
