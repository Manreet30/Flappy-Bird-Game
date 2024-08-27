import javax.swing.*;
public class App {
    public static void main(String[] args) throws Exception {
        //setting up our game frame ie the 360 by 640 screen that
        // is not resizable,setting location relative to null
        //jframe closes on pressing escape button


       int boardWidth=360;
       int boardHeight=640;

       JFrame frame=new JFrame("Flappy Bird");
        frame.setVisible(true);
        frame.setSize(boardWidth,boardHeight);
        frame.setLocationRelativeTo(null);
        frame.setResizable(false);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
         
        FlappyBird flappyBird=new FlappyBird();
        frame.add(flappyBird);
        frame.pack();   // to exclude dimensions of title bar from being covered in blue bg
        flappyBird.requestFocus();
        frame.setVisible(true);
        

    }
}
