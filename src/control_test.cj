/*
 * Tests for the root-package runtime control API and version constant.
 */
package matcang

@Test
class ControlTests {
    @TestCase
    func versionConstant() {
        @Expect(VERSION == "1.1.0")
    }

    @TestCase
    func threadControlRoundTrip() {
        let before = getNumThreads()
        @Expect(before >= 1)
        setNumThreads(2)
        @Expect(getNumThreads() == 2)
        setNumThreads(before)
        @Expect(getNumThreads() == before)
    }

    @TestCase
    func backendIntrospection() {
        @Expect(getNumProcs() >= 1)
        let config = getConfig()
        @Expect(config.contains("OpenBLAS"))
        @Expect(getCoreName().size > 0)
        let parallel = getParallel()
        @Expect(parallel >= 0 && parallel <= 2)
    }
}
