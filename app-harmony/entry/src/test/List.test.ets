import localUnitTest from './LocalUnit.test';
import contractMapperTest from './ContractMapper.test';
import coreFoundationTest from './core/CoreFoundation.test';

export default function testsuite() {
  localUnitTest();
  contractMapperTest();
  coreFoundationTest();
}
