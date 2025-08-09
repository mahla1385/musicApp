package com.example.musicplayer.codes_of_project;

import org.glassfish.tyrus.server.Server;
import java.util.Scanner;
import jakarta.websocket.server.ServerEndpoint;

public class Main {
    public static void main(String[] args) {
        String ipAddress = "192.168.1.3";
        Server server = new Server(ipAddress, 8080, "/", null, WebSocketServer.class);

        try {
            System.out.println(WebSocketServer.class.getAnnotation(ServerEndpoint.class));
            server.start();
            System.out.println("✅ WebSocket server started at ws://" + ipAddress + ":8080/ws");
            System.out.println("Press Enter to stop the server...");
            new Scanner(System.in).nextLine();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            server.stop();
            System.out.println("🔴 Server stopped.");
        }
    }
}