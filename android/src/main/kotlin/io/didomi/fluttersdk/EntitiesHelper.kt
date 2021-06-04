package io.didomi.fluttersdk
import com.google.gson.Gson
import io.didomi.sdk.Purpose
import io.didomi.sdk.Vendor
import java.util.*

// Class used to convert Didomi entities (Vendor, Purpose) from and to types that can be sent through the Flutter channels.
class EntitiesHelper {
    companion object {
        private val gson = Gson()
        // Convert a set of purposes into a list of maps.
        fun toListOfPurposes(purposes: Set<Purpose>): List<*> {
            val json = gson.toJsonTree(purposes)
            return gson.fromJson(json, List::class.java)
        }

        // Convert a set of vendors into a list of maps.
        fun toListOfVendors(vendors: Set<Vendor>): List<*> {
            val json = gson.toJsonTree(vendors)
            return gson.fromJson(json, List::class.java)
        }

        // Convert a purpose into a map.
        fun toPurposeMap(purpose: Purpose): HashMap<*, *> {
            val json = gson.toJsonTree(purpose)
            return gson.fromJson(json, HashMap::class.java)
        }

        // Convert a vendor into a map.
        fun toVendorMap(vendor: Vendor): HashMap<*, *> {
            val json = gson.toJsonTree(vendor)
            return gson.fromJson(json, HashMap::class.java)
        }
    }
}