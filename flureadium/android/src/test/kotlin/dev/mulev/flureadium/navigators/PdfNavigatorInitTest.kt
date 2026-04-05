package dev.mulev.flureadium.navigators

import dev.mulev.flureadium.FlutterPdfPreferences
import dev.mulev.flureadium.fragments.PdfReaderFragment
import dev.mulev.flureadium.models.PdfReaderViewModel
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertNotNull
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.mockConstruction
import org.readium.adapter.pdfium.navigator.PdfiumEngineProvider
import org.readium.r2.navigator.pdf.PdfNavigatorFactory
import org.readium.r2.shared.ExperimentalReadiumApi
import org.readium.r2.shared.publication.Publication
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Regression test for PdfNavigator.initNavigator() scope resolution.
 *
 * Bare `engineProvider!!` inside `PdfReaderViewModel.apply {}` resolved to
 * PdfReaderViewModel.engineProvider (null) instead of PdfNavigator.engineProvider.
 * The fix qualifies it as `this@PdfNavigator.engineProvider!!`.
 */
@OptIn(ExperimentalReadiumApi::class, ExperimentalCoroutinesApi::class)
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], manifest = Config.NONE)
internal class PdfNavigatorInitTest {

    private val testDispatcher = UnconfinedTestDispatcher()

    @BeforeTest
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
    }

    @AfterTest
    fun tearDown() {
        Dispatchers.resetMain()
    }

    private fun createNavigator(): PdfNavigator {
        return PdfNavigator(
            mock(Publication::class.java),
            null,
            mock(PdfNavigator.VisualListener::class.java),
            FlutterPdfPreferences()
        )
    }

    private fun PdfNavigator.getField(name: String): Any? {
        val field = PdfNavigator::class.java.getDeclaredField(name)
        field.isAccessible = true
        return field.get(this)
    }

    /**
     * Without the fix, initNavigator() throws NPE because PdfReaderViewModel.engineProvider
     * is null at construction time. With the fix, the outer PdfNavigator.engineProvider is
     * used instead.
     */
    @Test
    fun initNavigator_resolves_engineProvider_from_outer_scope() = runTest {
        val navigator = createNavigator()

        mockConstruction(PdfiumEngineProvider::class.java).use {
            mockConstruction(PdfNavigatorFactory::class.java).use {
                navigator.initNavigator()
            }
        }

        val fragment = navigator.getField("pdfNavigator") as PdfReaderFragment
        assertNotNull(fragment, "pdfNavigator fragment should be initialized")

        val vm = fragment.vm as PdfReaderViewModel
        assertNotNull(vm.navigatorFactory, "navigatorFactory must be set")
        assertNotNull(vm.engineProvider, "VM engineProvider must be set from outer PdfNavigator scope")
    }
}
