import localUnitTest from './LocalUnit.test';
import contractMapperTest from './ContractMapper.test';
import loginStateTest from './LoginState.test';
import coreFoundationTest from './core/CoreFoundation.test';

export default function testsuite() {
  localUnitTest();
  contractMapperTest();
  loginStateTest();
  coreFoundationTest();
}
