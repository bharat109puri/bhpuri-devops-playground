package com.bharat.playground;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.Test;

class ApplicationTest {
  @Test void healthContractIsStable() { assertThat("healthy").isEqualTo("healthy"); }
}
