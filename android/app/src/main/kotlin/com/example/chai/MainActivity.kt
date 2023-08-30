package com.example.chai

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.dantsu.escposprinter.EscPosPrinter
import com.dantsu.escposprinter.connection.DeviceConnection
import com.dantsu.escposprinter.connection.bluetooth.BluetoothConnection
import com.dantsu.escposprinter.exceptions.EscPosBarcodeException
import com.dantsu.escposprinter.exceptions.EscPosConnectionException
import com.dantsu.escposprinter.exceptions.EscPosEncodingException
import com.dantsu.escposprinter.exceptions.EscPosParserException
import com.example.chai.AsyncBluetoothEscPosPrint
import com.example.chai.AsyncEscPosPrinter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.json.JSONArray
import org.json.JSONObject
import java.time.LocalDateTime
import java.util.function.Consumer
import kotlin.math.log

class MainActivity() : FlutterActivity() {
    private var selectedDevice: BluetoothConnection? = null
    private var itemDataList : JSONArray? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(
                { call: MethodCall, result: MethodChannel.Result? ->
                    if ((call.method == "print")) {

                        var s = call.arguments
                       itemDataList = JSONArray(call.arguments as String)
                        Log.d("data",s as String);
                        browseBluetoothDevice()
                    }
                })
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (grantResults.size > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            when (requestCode) {
                PERMISSION_BLUETOOTH -> //                    this.browseBluetoothDevice();
                    browseBluetoothDevice()
            }
        }
    }

    @Throws(EscPosConnectionException::class,
        EscPosEncodingException::class,
        EscPosBarcodeException::class,
        EscPosParserException::class)
    fun printBluetooth() {
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(this,
                arrayOf(Manifest.permission.BLUETOOTH_CONNECT),
                PERMISSION_BLUETOOTH)
        } else {

            AsyncBluetoothEscPosPrint(this).execute(this.getAsyncEscPosPrinter(selectedDevice));
        }
    }

    fun browseBluetoothDevice() {
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        val deviceList = bluetoothAdapter.bondedDevices
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            deviceList.forEach(Consumer { bluetoothDevice: BluetoothDevice ->
                if ((bluetoothDevice.getAddress() == "86:67:7A:B5:8F:82")) {
                    selectedDevice = BluetoothConnection(bluetoothDevice)
                    try {
                        printBluetooth()
                    } catch (e: EscPosConnectionException) {
                        e.printStackTrace()
                    } catch (e: EscPosEncodingException) {
                        e.printStackTrace()
                    } catch (e: EscPosBarcodeException) {
                        e.printStackTrace()
                    } catch (e: EscPosParserException) {
                        e.printStackTrace()
                    }
                }
            }
            )
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun getAsyncEscPosPrinter(printerConnection: DeviceConnection?): AsyncEscPosPrinter {
        val printer = AsyncEscPosPrinter(printerConnection, 203, 80f, 32)
        var iteratedData = "";
        var ultimateTotal = 0
        var billId = ""
        for (i in 0 until (itemDataList?.length() ?:0 ))
        {
            var data = itemDataList?.getString(i)
            var item = JSONObject(data)
            var name = item?.get("item_Name")
            var qty = item?.getInt("item_Qty")
            var price = item?.getInt("item_Price")
            var total  = qty!! * price!!
            billId = item.getString("bill_id")

            ultimateTotal += total

         iteratedData = iteratedData.plus(String.format("[L]<b>%s.%s</b>[R][R][R][R][R][R][R][R][R]<b>%s  *  %s  = %s<b>" + "\n\n",i+1,name,qty.toString(),price.toString(),total.toString()))
        }
        printer.setTextToPrint(
            "[C][C]<font size='big'> <b>DFC SHOP<b></font>" +
                    "\n" + "\n" +
                    "[R][R]<font size='normal'>KAKINADA, AP,INDIA</font>" +
                    "\n" +
                    "[R]<font size='normal'>Bill NO : #$billId</font>" +
                    "\n" +
                    "[C]================================================" +
                    "\n" +
                    "[L]<b>SNO  ITEM</b>[R][R][R][R]<b>PRICE    QTY     AMT<b>" +
                    "\n\n" +
                     iteratedData +
                    "[C]================================================" + "\n" +
                    "[L]<font size='big'>Total</font>" + "[R][R][R][R][R][R][R][R][R][R][R][R][R][R]<font size='big'><b>$ultimateTotal<b></font>" + '\n' +
                    "[C]================================================" +
                    "\n\n" +
                    "[C]<font size='normal'>\t\tTHANK YOU VISIT US AGAIN</font>" +
                    "\n" +
                    "[R]<font size='normal'> ${LocalDateTime.now().toString().split(".")[0]}</font>"
        )
        return printer
    }

    companion object {
        val CHANNEL = "print"
        val PERMISSION_BLUETOOTH = 1
    }
}