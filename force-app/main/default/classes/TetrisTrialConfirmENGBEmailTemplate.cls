/**
    Tetris Trial Confirm Email Notification EN GB
 */
public class TetrisTrialConfirmENGBEmailTemplate  extends TetrisEmailTemplateImpl {
    public TetrisTrialConfirmENGBEmailTemplate () {
        super('TetrisTrialConfirmationENGB',
                new List<TetrisEmailTemplateField>{new TetrisEmailTemplateField('referenceName', TetrisEmailTemplateDataType.STRING_FIELD, true),
                                                   new TetrisEmailTemplateField('firstName', TetrisEmailTemplateDataType.STRING_FIELD, true),
                                                   new TetrisEmailTemplateField('lastName', TetrisEmailTemplateDataType.STRING_FIELD, true),
                                                   new TetrisEmailTemplateField('createdDate', TetrisEmailTemplateDataType.DATE_FIELD, true)});
    }
}