import java.net.DatagramPacket
import java.net.DatagramSocket

object SocketServerExample {

    @JvmStatic
    fun main(args: Array<String>) {
        val socket = DatagramSocket(123)
        val buffer = ByteArray(1)
        val request = DatagramPacket(buffer, buffer.size)
        while (true) {
            println("Waiting for content")
            socket.receive(request)
            println("Received bytes: ${buffer.contentToString()}")
        }
    }
}
